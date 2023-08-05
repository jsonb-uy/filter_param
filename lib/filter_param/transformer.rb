module FilterParam
  class Transformer < Parslet::Transform
    include AST

    rule(null: simple(:null))      { Literals::Null.instance }
    rule(string: simple(:value))   { Literals::String.new(value) }
    rule(boolean: simple(:value))  { value == "true" ? Literals::Boolean::TRUE : Literals::Boolean::FALSE }
    rule(integer: simple(:value))  { Literals::Integer.new(value) }
    rule(decimal: simple(:value))  { Literals::Decimal.new(value) }
    rule(date: simple(:value))     { Literals::Date.new(value) }
    rule(datetime: simple(:value)) { Literals::DateTime.new(value) }
    rule(exp: simple(:exp))        { exp }
    rule(group: simple(:exp))      { Group.new(exp) }
    rule(attribute: simple(:attribute_name)) do
      Field.new(attribute_name, definition.field_type(attribute_name))
    end
    rule(operator: simple(:operator), right: simple(:exp)) { Expressions::UnaryExpression.new(operator, exp) }
    rule(attribute: simple(:attribute_name), operator: simple(:operator)) do
      attribute_declaration = definition.field_info(attribute_name)
      attribute = Field.new(attribute_declaration[:type], attribute_name, attribute_declaration[:rename])

      Expressions::UnaryExpression.new(operator, attribute)
    end
    rule(left: simple(:left), operator: simple(:operator), right: simple(:right)) do
      Expressions::BinaryExpression.new(operator, left, right)
    end
    rule(attribute: simple(:attribute_name), operator: simple(:operator), val: simple(:literal)) do
      attribute_declaration = definition.field_info(attribute_name)
      attribute = Field.new(attribute_declaration[:type], attribute_name, attribute_declaration[:rename])

      Expressions::BinaryExpression.new(operator, attribute, literal.type_cast(attribute.type))
    end
  end
end

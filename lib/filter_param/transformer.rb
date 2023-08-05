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
    rule(op: simple(:op), right: simple(:exp)) { Expressions::UnaryExpression.new(op, exp) }
    rule(f: simple(:f), op: simple(:op)) do
      Expressions::UnaryExpression.new(op, Field.new(f, definition.field_type(f)))
    end
    rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
      Expressions::BinaryExpression.new(op, left, right)
    end
    rule(f: simple(:f), op: simple(:op), val: simple(:literal)) do
      field = Field.new(f, definition.field_type(f))

      Expressions::BinaryExpression.new(op, field, literal.type_cast(field.type))
    end
  end
end

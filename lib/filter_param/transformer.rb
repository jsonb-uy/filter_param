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
    rule(scope: simple(:name), args: simple(:scope_arg)) do
      scope_args = scope_arg.nil? ? [] : [scope_arg]

      AST::Scope.new(name, scope_args)
    end
    rule(scope: simple(:name), args: sequence(:scope_args)) { AST::Scope.new(name, scope_args) }
    rule(operator: simple(:operator), right: simple(:operand)) do
      Expressions::UnaryExpression.new(operator, operand)
    end
    rule(attribute: simple(:attribute_name), operator: simple(:operator)) do
      attribute = Attribute.new(attribute_name)

      Expressions::UnaryExpression.new(operator, attribute)
    end
    rule(left: simple(:left), operator: simple(:operator), right: simple(:right)) do
      Expressions::BinaryExpression.new(operator, left, right)
    end
    rule(attribute: simple(:attribute_name), operator: simple(:operator), val: simple(:literal)) do
      attribute = Attribute.new(attribute_name)

      Expressions::BinaryExpression.new(operator, attribute, literal)
    end
  end
end

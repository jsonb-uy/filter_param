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
    rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(op, exp) }
    rule(f: simple(:f), op: simple(:op)) { UnaryExpression.new(op, Field.new(f)) }
    rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
      LogicalExpression.new(op, left, right)
    end
    rule(f: simple(:f), op: simple(:op), val: simple(:literal)) do
      field = Field.new(f)
      declared_type = definition.field_type(field.name)

      Comparison.new(op, field, literal.type_cast(declared_type))
    end
  end
end

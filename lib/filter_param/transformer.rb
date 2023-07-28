module FilterParam
  class Transformer < Parslet::Transform
    include AST

    rule(null: simple(:null))      { Literal.new(:null) }
    rule(string: simple(:value))   { Literal.new(:string, value) }
    rule(boolean: simple(:value))  { Literal.new(:boolean, value) }
    rule(integer: simple(:value))  { Literal.new(:integer, value) }
    rule(decimal: simple(:value))  { Literal.new(:decimal, value) }
    rule(date: simple(:value))     { Literal.new(:date, value) }
    rule(datetime: simple(:value)) { Literal.new(:datetime, value) }
    rule(exp: simple(:exp))        { exp }
    rule(group: simple(:exp))      { Group.new(exp) }
    rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(op, exp) }
    rule(f: simple(:f), op: simple(:op)) { UnaryExpression.new(op, Field.new(f)) }
    rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
      LogicalExpression.new(op, left, right)
    end
    rule(f: simple(:f), op: simple(:op), val: simple(:val)) do
      field = Field.new(f)
      declared_type = definition.field_type(field.name)
      literal = val.typecast!(declared_type)

      Comparison.new(op, field, literal)
    end
  end
end

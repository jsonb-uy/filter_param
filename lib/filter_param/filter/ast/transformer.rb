module FilterParam
  module Filter
    module AST
      class Transformer < Parslet::Transform
        include Nodes

        rule(null: simple(:null)) { Null.instance }
        rule(exp: simple(:exp)) { exp }
        rule(group: simple(:exp)) { Group.new(exp) }
        rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(exp, op) }
        rule(f: simple(:f), op: simple(:op)) { UnaryExpression.new(Field.new(f), op) }
        rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
          BinaryExpression.new(left, op, right)
        end
        rule(f: simple(:f), op: simple(:op), val: simple(:val)) do
          field = Field.new(f)
          field_type = definition.field_type(field.name)
          literal = val.is_a?(Literal) ? val : Literal.new(val, field_type)

          BinaryExpression.new(field, op, literal)
        end
      end
    end
  end
end

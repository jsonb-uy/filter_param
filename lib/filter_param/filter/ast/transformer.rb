module FilterParam
  module Filter
    module AST
      class Transformer < Parslet::Transform
        include Nodes

        rule(null: simple(:null)) { Literal.new(:null) }
        rule(exp: simple(:exp)) { exp }
        rule(group: simple(:exp)) { Group.new(exp) }
        rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(op, exp) }
        rule(f: simple(:f), op: simple(:op)) { UnaryExpression.new(op, Field.new(f)) }
        rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
          LogicalExpression.new(op, left, right)
        end
        rule(f: simple(:f), op: simple(:op), val: simple(:val)) do
          field = Field.new(f)
          field_type = definition.field_type(field.name) || :string
          literal = val.is_a?(Literal) ? val : Literal.new(field_type, val)

          Comparison.new(op, field, literal)
        end
      end
    end
  end
end

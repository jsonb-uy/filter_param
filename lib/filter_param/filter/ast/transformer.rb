require "bigdecimal"
require "date"
require_relative "nodes/node"
require_relative "nodes/literal"
require_relative "nodes/field"
require_relative "nodes/group"
require_relative "nodes/binary_expression"
require_relative "nodes/unary_expression"

module FilterParam
  module Filter
    module AST
      class Transformer < Parslet::Transform
        include AST

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
          literal = Literal.new(val, field_type)

          BinaryExpression.new(field, op, literal)
        end
      end
    end
  end
end

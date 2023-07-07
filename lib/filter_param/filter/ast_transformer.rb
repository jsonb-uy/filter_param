require "bigdecimal"
require "date"
require_relative "ast/node"
require_relative "ast/literal"
require_relative "ast/field"
require_relative "ast/group"
require_relative "ast/binary_expression"
require_relative "ast/unary_expression"

module FilterParam
  module Filter
    class AstTransformer < Parslet::Transform
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

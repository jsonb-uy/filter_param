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

      rule(exp: simple(:exp))      { exp }
      rule(group: simple(:exp))    { Group.new(exp) }
      rule(null: simple(:null))    { Literal.new(nil, :null) }
      rule(string: simple(:val))   { Literal.new(val.to_s, :string) }
      rule(int: simple(:val))      { Literal.new(Integer(val), :numeric) }
      rule(boolean: simple(:val))  { Literal.new(val == "true", :boolean) }
      rule(decimal: simple(:val))  { Literal.new(BigDecimal(val), :numeric) }
      rule(datetime: simple(:val)) { Literal.new(DateTime.iso8601(val), :datetime) }
      rule(date: simple(:val))     { Literal.new(Date.iso8601(val), :date) }
      rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(exp, op) }
      rule(f: simple(:f), op: simple(:op)) do
        UnaryExpression.new(Field.new(f), op).validate!(definition)
      end
      rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
        BinaryExpression.new(left, op, right)
      end
      rule(f: simple(:f), op: simple(:op), val: simple(:val)) do
        BinaryExpression.new(Field.new(f), op, val)
      end
    end
  end
end

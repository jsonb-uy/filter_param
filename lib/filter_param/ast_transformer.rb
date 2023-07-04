require "bigdecimal"
require "date"

module FilterParam
  class ASTTransformer < Parslet::Transform
    include AST

    rule(null: simple(:null)) { nil }
    rule(string: simple(:val)) { val }
    rule(int: simple(:val)) { Integer(val) }
    rule(boolean: simple(:val)) { val == "true" }
    rule(decimal: simple(:val)) { BigDecimal(val) }
    rule(datetime: simple(:val)) { DateTime.iso8601(val) }
    rule(date: simple(:val)) { Date.iso8601(val) }
    rule(left: simple(:left), op: simple(:op), right: simple(:right)) do
      BinaryExpression.new(left, op, right)
    end
    rule(op: simple(:op), right: simple(:exp)) { UnaryExpression.new(exp, op) }
    rule(f: simple(:f), op: simple(:op), val: simple(:val)) do
      BinaryExpression.new(Field.new(f), op, val)
    end
    rule(f: simple(:f), op: simple(:op)) { UnaryExpression.new(Field.new(f), op) }
    rule(group: simple(:exp)) { GroupingExpression.new(exp) }
    rule(exp: simple(:exp)) { exp }
  end
end

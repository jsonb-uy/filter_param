module FilterParam
  module AST
    module Expressions
      class Expression < Node
        attr_reader :operator, :operands

        def initialize(operator, *operands)
          super()

          @operator = operator.to_sym
          @operands = operands
        end
      end

      class UnaryExpression < Expression
        attr_reader :operand

        def initialize(operator, operand)
          super(operator, operand)

          @operand = operand
        end
      end

      class BinaryExpression < Expression
        attr_reader :left_operand, :right_operand

        def initialize(operator, left_operand, right_operand)
          super(operator, left_operand, right_operand)

          @left_operand = left_operand
          @right_operand = right_operand
        end
      end
    end
  end
end

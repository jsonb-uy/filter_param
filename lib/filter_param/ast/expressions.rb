module FilterParam
  module AST
    module Expressions
      class Expression < Node
        attr_reader :operator_symbol, :operands

        def initialize(operator_symbol, *operands)
          super()

          @operator_symbol = operator_symbol
          @operands = operands
        end

        def operator
          @operator ||= Operators::Operator.for(operator_symbol)
        end
      end

      class UnaryExpression < Expression
        attr_reader :operand

        def initialize(operator_symbol, operand)
          super(operator_symbol, operand)

          @operand = operand
        end
      end

      class BinaryExpression < Expression
        attr_reader :left_operand, :right_operand

        def initialize(operator_symbol, left_operand, right_operand)
          super(operator_symbol, left_operand, right_operand)

          @left_operand = left_operand
          @right_operand = right_operand
        end
      end
    end
  end
end

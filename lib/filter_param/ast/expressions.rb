module FilterParam
  module AST
    module Expressions
      class Expression < Node
        attr_reader :operator, :operands

        def initialize(operator, *operands)
          @operator = operator
          @operands = operands
        end

        def inverse
          nil
        end
      end

      class UnaryExpression < Expression
        attr_reader :operand

        def initialize(operator, operand)
          super(operator, operands)

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

      class AttributeExpression < BinaryExpression
        alias attribute left_operand
        alias literal right_operand

        def initialize(operator, attribute, literal)
          super(operator, attribute, literal)

          validate_literal!(literal)
        end

        private

        def literal_allowed?(literal)
          false
        end

        def validate_literal!(literal)
          return if literal_allowed?(literal)

          value = literal.value.present? ? "(#{literal.value})" : ""
          raise FilterParam::InvalidLiteral.new(
            "Unexpected #{literal.type} value#{value} for operator '#{op}'."
          )
        end
      end
    end
  end
end

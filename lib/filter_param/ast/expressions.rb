module FilterParam
  module AST
    module Expressions
      class Expression < Node
        attr_reader :operator, :operands

        def initialize(operator, *operands)
          super()

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

        private

        def visit_method
          :visit_unary_expression
        end
      end

      class BinaryExpression < Expression
        attr_reader :left_operand, :right_operand

        def initialize(operator, left_operand, right_operand)
          super(operator, left_operand, right_operand)

          @left_operand = left_operand
          @right_operand = right_operand
        end

        private

        def visit_method
          :visit_binary_expression
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

        def literal_allowed?(_)
          true
        end

        def validate_literal!(literal)
          return if literal_allowed?(literal)

          value = literal.value.present? ? "(#{literal.value})" : ""
          raise FilterParam::InvalidLiteral.new(
            "Unexpected #{literal.type} value#{value} for operator '#{op}'."
          )
        end
      end

      class StringAttributeExpression < AttributeExpression
        private

        def literal_allowed?(literal)
          literal.is_a?(Literals::String)
        end
      end

      class NonNullAttributeExpression < AttributeExpression
        private

        def literal_allowed?(literal)
          !literal.is_a?(Literals::Null)
        end
      end

      class And < BinaryExpression; end
      class Or < BinaryExpression; end
      class EqCi < StringAttributeExpression; end
      class Co < StringAttributeExpression; end
      class Sw < StringAttributeExpression; end
      class Ew < StringAttributeExpression; end

      class Not < UnaryExpression
        def inverse
          @inverse ||= operand
        end
      end

      class Pr < UnaryExpression
        def inverse
          @inverse ||= Npr.new(operand)
        end
      end

      class Npr < UnaryExpression
        def inverse
          @inverse ||= Pr.new(operand)
        end
      end

      class Eq < AttributeExpression
        def inverse
          @inverse ||= Neq.new(attribute, literal)
        end
      end

      class Neq < AttributeExpression
        def inverse
          @inverse ||= Eq.new(attribute, literal)
        end
      end

      class Ge < NonNullAttributeExpression; end
      class Gt < NonNullAttributeExpression; end
      class Le < NonNullAttributeExpression; end
      class Lt < NonNullAttributeExpression; end
    end
  end
end

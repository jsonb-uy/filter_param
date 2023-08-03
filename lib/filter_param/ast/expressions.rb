module FilterParam
  module AST
    module Expressions
      class Expression < Node
        def self.for(operator)
          "Expressions::#{operator.to_s.camelize}".safe_constantize
        end

        def self.operator
          @operator ||= self.class.name.demodulize.underscore.to_sym
        end

        attr_reader :operands

        def initialize(*operands)
          super()

          @operands = operands
        end

        def operator
          self.class.operator
        end

        def negation
          nil
        end
      end

      class UnaryExpression < Expression
        attr_reader :operand

        def initialize(operand)
          super(operand)

          @operand = operand
        end

        private

        def visit_method
          :visit_unary_expression
        end
      end

      class BinaryExpression < Expression
        attr_reader :left_operand, :right_operand

        def initialize(left_operand, right_operand)
          super(left_operand, right_operand)

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

        def initialize(attribute, literal)
          super(attribute, literal)

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
      class EqualCaseInsensitive < StringAttributeExpression; end
      class Contains < StringAttributeExpression; end
      class StartsWith < StringAttributeExpression; end
      class EndsWith < StringAttributeExpression; end

      class Not < UnaryExpression
        def negation
          @negation ||= operand
        end
      end

      class Pr < UnaryExpression
        def negation
          @negation ||= NotPresent.new(operand)
        end
      end

      class NotPresent < UnaryExpression
        def negation
          @negation ||= Present.new(operand)
        end
      end

      class Equal < AttributeExpression
        def negation
          @negation ||= Equal.new(attribute, literal)
        end
      end

      class NotEqual < AttributeExpression
        def negation
          @negation ||= NotEqual.new(attribute, literal)
        end
      end

      class GreaterThenEqual < NonNullAttributeExpression; end
      class GreaterThan < NonNullAttributeExpression; end
      class LessThanEqual < NonNullAttributeExpression; end
      class LessThan < NonNullAttributeExpression; end
    end
  end
end

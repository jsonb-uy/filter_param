module FilterParam
  module AST
    module Operators
      class Operator < Node
        class << self
          def registry
            @@registry ||= {}
          end

          def register(operator_symbol, clazz, type = :binary)
            registry[operator_symbol] ||= {}
            registry[operator_symbol] ||= { class: clazz, type: type }
            operator_symbol
          end

          def for(operator_symbol)
            registry[operator_symbol][:class]
          end

          def inverse_operator
            nil
          end
        end
      end

      class AttributeOperator < Operator
        class << self
          def operate(attribute, literal)
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
              "Unexpected #{literal.type} value#{value} for operator '#{self.class.operator_symbol}'."
            )
          end
        end
      end

      class StringAttributeOperator < AttributeOperator
        class << self
          private

          def literal_allowed?(literal)
            literal.is_a?(Literals::String)
          end
        end
      end

      class NonNullAttributeOperator < AttributeOperator
        class << self
          private

          def literal_allowed?(literal)
            !literal.is_a?(Literals::Null)
          end
        end
      end

      class And < Operator
        class << self
          def operator_symbol
            :and
          end
        end
      end

      class Or < Operator
        class << self
          def operator_symbol
            :or
          end
        end
      end

      class EqualCaseInsensitive < StringAttributeOperator
        class << self
          def operator_symbol
            :eq_ci
          end
        end
      end

      class Contains < StringAttributeOperator
        class << self
          def operator_symbol
            :co
          end
        end
      end

      class StartsWith < StringAttributeOperator
        class << self
          def operator_symbol
            :sw
          end
        end
      end

      class EndsWith < StringAttributeOperator
        class << self
          def operator_symbol
            :ew
          end
        end
      end

      class Not < Operator
        class << self
          def operator_symbol
            :not
          end
        end
      end

      class Pr < Operator
        def inverse
          @inverse ||= NotPresent.new(operand)
        end
      end

      class NotPresent < Operator
        def inverse
          @inverse ||= Present.new(operand)
        end
      end

      class Equal < AttributeOperator
        def inverse
          @inverse ||= Equal.new(attribute, literal)
        end
      end

      class NotEqual < AttributeOperator
        def inverse
          @inverse ||= NotEqual.new(attribute, literal)
        end
      end

      class GreaterThenEqual < NonNullAttributeOperator; end
      class GreaterThan < NonNullAttributeOperator; end
      class LessThanEqual < NonNullAttributeOperator; end
      class LessThan < NonNullAttributeOperator; end
    end
  end
end

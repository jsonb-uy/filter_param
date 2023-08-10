module FilterParam
  module AST
    module Literals
      class Integer < Literal
        def initialize(value)
          @value = Integer(value.to_s)
        rescue ArgumentError
          raise InvalidLiteral.new("Invalid Integer: #{value}")
        end

        def data_type
          :integer
        end

        private

        def to_boolean
          return Literals::Boolean::FALSE if value.zero?

          Literals::Boolean::TRUE
        end

        def to_string
          Literals::String.new(value)
        end

        def to_integer
          self
        end

        def to_decimal
          Literals::Decimal.new(value)
        end
      end
    end
  end
end

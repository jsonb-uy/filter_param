require "bigdecimal"

module FilterParam
  module AST
    module Literals
      class Decimal < Integer
        def initialize(value)
          @value = BigDecimal(value.to_s)
        rescue ArgumentError
          raise InvalidLiteral.new("Invalid Decimal: #{value}")
        end

        def data_type
          :decimal
        end

        private

        def to_integer
          Literals::Integer.new(value.to_i)
        end

        def to_decimal
          self
        end
      end
    end
  end
end

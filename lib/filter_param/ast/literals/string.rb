module FilterParam
  module AST
    module Literals
      class String < Literal
        def initialize(value)
          @value = value.to_s
        end

        def data_type
          :string
        end

        private

        def to_boolean
          return Literals::Boolean::TRUE if value.downcase == "true"

          Literals::Boolean::FALSE
        end

        def to_string
          self
        end

        def to_integer
          Literals::Integer.new(value)
        end

        def to_decimal
          Literals::Decimal.new(value)
        end

        def to_date
          Literals::Date.new(value)
        end

        def to_datetime
          Literals::DateTime.new(value)
        end
      end
    end
  end
end

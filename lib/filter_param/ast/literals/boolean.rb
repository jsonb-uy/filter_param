module FilterParam
  module AST
    module Literals
      class Boolean < Literal
        def initialize(value)
          @value = (value.to_s == "true")
        end

        private_class_method :new

        TRUE = new("true")
        FALSE = new("false")

        private

        def to_boolean
          self
        end

        def to_string
          Literals::String.new(value)
        end

        def to_integer
          Literals::Integer.new(value ? 1 : 0)
        end

        def to_decimal
          Literals::Decimal.new(value ? 1.0 : 0.0)
        end
      end
    end
  end
end

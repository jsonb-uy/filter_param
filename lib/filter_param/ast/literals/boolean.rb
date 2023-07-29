module FilterParam
  module AST
    module Literals
      class Boolean < Literal
        TRUE = new("true")
        FALSE = new("false")

        private_class_method :new

        def initialize(value)
          @value = value.to_s == "true"
        end

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

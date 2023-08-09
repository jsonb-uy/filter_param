module FilterParam
  module Operators
    class AttributeFilterOperator < Operator
      class << self
        def sql(attribute, value)
          validate_value!(value)
        end

        def value_valid?(value)
          true
        end

        private

        def validate_value!(value)
          return if value_valid?(value)

          raise FilterParam::InvalidLiteral.new(
            "Unexpected value#{value} for operator '#{tag}'."
          )
        end
      end
    end
  end
end

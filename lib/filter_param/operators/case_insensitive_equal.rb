module FilterParam
  module Operators
    class CaseInsensitiveEqual < AttributeFilterOperator
      def self.tag
        :eq_ci
      end

      def self.value_valid?(value)
        value.is_a?(String)
      end

      def self.sql(attribute_name, value)
        "lower(#{field}) = #{quote(value.downcase)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::CaseInsensitiveEqual)

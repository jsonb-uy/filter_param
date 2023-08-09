module FilterParam
  module Operators
    class CaseInsensitiveEqual < FieldValueFilterOperator
      operator_tag :eq_ci
      field_type :string

      def self.sql(field, value)
        super

        "lower(#{field.sql_name}) = #{sql_quote(value.downcase)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::CaseInsensitiveEqual)

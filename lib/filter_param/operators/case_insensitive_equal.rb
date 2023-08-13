module FilterParam
  module Operators
    class CaseInsensitiveEqual < FieldFilterOperator
      operator_tag :eq_ci
      operand_data_type :string

      def self.sql(field, literal)
        super

        "lower(#{field.actual_name}) = #{sql_quote(literal.value.downcase)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::CaseInsensitiveEqual)

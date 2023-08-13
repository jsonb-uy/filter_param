module FilterParam
  module Operators
    class StartsWith < FieldFilterOperator
      operator_tag :sw
      operand_data_type :string

      def self.sql(field, literal)
        super

        pattern = "#{literal.value}%"

        "#{field.actual_name} LIKE #{sql_quote(pattern)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::StartsWith)

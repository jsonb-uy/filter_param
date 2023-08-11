module FilterParam
  module Operators
    class Contains < FieldFilterOperator
      operator_tag :co
      operand_data_type :string

      def self.sql(field, literal)
        super

        pattern = "%#{literal.value}%"

        "#{field.sql_name} LIKE #{sql_quote(pattern)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Contains)

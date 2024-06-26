module FilterParam
  module Operators
    class GreaterThanEqual < FieldFilterOperator
      operator_tag :ge
      operand_data_type :string, :integer, :decimal, :date, :datetime

      def self.sql(field, literal)
        super

        "#{field.actual_name} >= #{sql_quote(literal.value)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::GreaterThanEqual)

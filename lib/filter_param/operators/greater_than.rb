module FilterParam
  module Operators
    class GreaterThan < FieldFilterOperator
      operator_tag :gt
      operand_data_type :string, :integer, :decimal, :date, :datetime

      def self.sql(field, literal)
        super

        "#{field.actual_name} > #{sql_quote(literal.value)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::GreaterThan)

module FilterParam
  module Operators
    class GreaterThanEqual < FieldFilterOperator
      operator_tag :ge
      literal_data_type :string, :integer, :decimal, :date, :date_time

      def self.sql(field, literal)
        super

        "#{field.sql_name} >= #{sql_quote(literal.value)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::GreaterThanEqual)

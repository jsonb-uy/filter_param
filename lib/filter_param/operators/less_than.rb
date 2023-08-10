module FilterParam
  module Operators
    class LessThan < FieldFilterOperator
      operator_tag :lt
      literal_data_type :string, :integer, :decimal, :date, :datetime

      def self.sql(field, literal)
        super

        "#{field.sql_name} < #{sql_quote(literal.value)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::LessThan)

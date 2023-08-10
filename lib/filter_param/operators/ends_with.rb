module FilterParam
  module Operators
    class EndsWith < FieldFilterOperator
      operator_tag :ew
      literal_data_type :string

      def self.sql(field, literal)
        super

        pattern = "%#{literal.value}"

        "#{field.sql_name} LIKE #{sql_quote(pattern)}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::EndsWith)

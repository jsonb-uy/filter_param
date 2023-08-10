module FilterParam
  module Operators
    class NotEqual < FieldValueFilterOperator
      operator_tag :neq

      def self.sql(field, value)
        return "#{field.sql_name} IS NOT NULL" if value.nil?

        "#{field.sql_name} != #{sql_quote(value)}"
      end

      def self.negated_sql(field, value)
        Operators::Equal.sql(field, value)
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::NotEqual)

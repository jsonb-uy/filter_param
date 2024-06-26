module FilterParam
  module Operators
    class NotEqual < FieldFilterOperator
      operator_tag :ne

      def self.sql(field, literal)
        return "#{field.actual_name} IS NOT NULL" if literal.value.nil?

        "#{field.actual_name} != #{sql_quote(literal.value)}"
      end

      def self.negated_sql(field, literal)
        Operators::Equal.sql(field, literal)
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::NotEqual)

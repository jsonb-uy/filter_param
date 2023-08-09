module FilterParam
  module Operators
    class Equal < FieldValueFilterOperator
      operator_tag :eq

      def self.sql(field, value)
        super

        return "#{field.sql_name} IS NULL" if value.nil?

        "#{field.sql_name} = #{sql_quote(value)}"
      end

      def self.negated_sql(field, value)
        Operators::NotEqual.sql(field, value)
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Equal)

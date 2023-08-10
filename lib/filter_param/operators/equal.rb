module FilterParam
  module Operators
    class Equal < FieldFilterOperator
      operator_tag :eq

      def self.sql(field, literal)
        super

        return "#{field.sql_name} IS NULL" if literal.value.nil?

        "#{field.sql_name} = #{sql_quote(literal.value)}"
      end

      def self.negated_sql(field, literal)
        Operators::NotEqual.sql(field, literal)
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Equal)

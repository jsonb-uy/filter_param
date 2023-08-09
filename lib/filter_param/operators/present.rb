module FilterParam
  module Operators
    class Present < FieldOperator
      operator_tag :pr

      def self.sql(field)
        super

        return "#{field.sql_name} IS NOT NULL" unless field.type == :string

        "(#{field.sql_name} IS NOT NULL AND TRIM(#{field.sql_name}) != '')"
      end

      def self.negated_sql(field)
        return "#{field.sql_name} IS NULL" unless field.type == :string

        "(#{field.sql_name} IS NULL OR TRIM(#{field.sql_name}) = '')"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Present)

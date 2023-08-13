module FilterParam
  module Operators
    class Present < FieldFilterOperator
      operator_tag :pr

      def self.sql(field)
        return "#{field.actual_name} IS NOT NULL" unless field.type == :string

        "(#{field.actual_name} IS NOT NULL AND TRIM(#{field.actual_name}) != '')"
      end

      def self.negated_sql(field)
        return "#{field.actual_name} IS NULL" unless field.type == :string

        "(#{field.actual_name} IS NULL OR TRIM(#{field.actual_name}) = '')"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Present)

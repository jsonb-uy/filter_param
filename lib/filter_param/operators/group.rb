module FilterParam
  module Operators
    class Group < Operator
      operator_tag :group, internal: true

      def self.sql(expression)
        "(#{expression})"
      end

      def self.negated_sql(expression)
        "NOT (#{expression})"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Group)

module FilterParam
  module Operators
    class Not < AttributeFilterOperator
      def self.tag
        :not
      end

      def self.sql(expression_operator, *expression_operands)
        operator = Operator.for(expression_operator)

        "NOT #{operator.sql(*expression_operands)}"
      end

      def self.negated_sql(expression_operator, *expression_operands)
        operator = Operator.for(expression_operator)

        operator.sql(*expression_operands)
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::Not)

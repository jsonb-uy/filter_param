module FilterParam
  module Operators
    class Not < Operator
      operator_tag :not

      def self.sql(expression_operator, *expression_operands)
        operator = Operator.for(expression_operator)
        return operator.negated_sql(*expression_operands) if operator.respond_to?(:negated_sql)

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

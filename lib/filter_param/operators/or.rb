module FilterParam
  module Operators
    class Or < Operator
      operator_tag :or

      def self.sql(left, right)
        "#{left} OR #{right}"
      end
    end

    Operator.register(Or)
  end
end

FilterParam::Operator.register(FilterParam::Operators::Or)

module FilterParam
  module Operators
    class And < Operator
      operator_tag :and

      def self.sql(left, right)
        "#{left} AND #{right}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::And)

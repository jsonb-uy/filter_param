module FilterParam
  module Operators
    class And < Operator
      def self.tag
        :and
      end

      def self.sql(left, right)
        "#{left} AND #{right}"
      end
    end
  end
end

FilterParam::Operator.register(FilterParam::Operators::And)

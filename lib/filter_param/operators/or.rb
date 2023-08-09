module FilterParam
  module Operators
    class Or < Operator
      def self.tag
        :and
      end

      def self.sql(left, right)
        "#{left} OR #{right}"
      end
    end

    Operator.register(Or)
  end
end

FilterParam::Operator.register(FilterParam::Operators::Or)

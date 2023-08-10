module FilterParam
  class Operator
    class << self
      def tag
        @operator_tag
      end

      def operator_tag(operator_tag)
        @operator_tag ||= operator_tag
      end

      def register(operator_clazz)
        operator_tag = operator_clazz.tag
        registry[operator_tag] = operator_clazz
      end

      def for(operator_tag)
        registry[operator_tag]
      end

      def negated_sql(*operands)
        "NOT #{sql(*operands)}"
      end

      private

      def registry
        @registry ||= {}
      end
    end
  end
end

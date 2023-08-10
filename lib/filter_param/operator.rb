module FilterParam
  class Operator
    class << self
      def tag
        @operator_tag
      end

      def internal?
        @internal_operator
      end

      def operator_tag(operator_tag, options = {})
        @operator_tag ||= operator_tag
        @internal = options[:internal].presence || false
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

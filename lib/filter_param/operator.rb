module FilterParam
  class Operator
    class << self
      def register(operator_clazz)
        operator_tag = operator_clazz.tag.to_s
        registry[operator_tag] ||= operator_clazz
      end

      def reset_registry!
        @registry = {}

        true
      end

      def for(operator_tag)
        registry[operator_tag.to_s]
      end

      def negated_sql(*operands)
        "NOT #{sql(*operands)}"
      end

      private

      def quote(value)
        ActiveRecord::Base.connection.quote(value)
      end

      def registry
        @registry ||= {}
      end
    end
  end
end

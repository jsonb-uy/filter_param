module FilterParam
  class Operator
    class << self
      def type
        return :unary if method(:sql).arity == 1

        :binary
      end

      def operator_tag(operator_tag)
        @operator_tag ||= operator_tag
      end

      def register(operator_clazz)
        operator_tag = operator_clazz.tag
        registry[operator_tag] = operator_clazz
      end

      def tag
        @operator_tag
      end

      def for(operator_tag)
        registry[operator_tag]
      end

      def negated_sql(*operands)
        "NOT #{sql(*operands)}"
      end

      def binaries
        @binaries ||= registry.values
                              .select { |op| op < self && op.type == :binary }
                              .map(&:tag)
      end

      def unaries
        @unaries ||= registry.values
                             .select { |op| op < self && op.type == :unary }
                             .map(&:tag)
      end

      private

      def registry
        @@registry ||= {}
      end
    end
  end
end

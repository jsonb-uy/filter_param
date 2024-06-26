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

      def binaries
        with_type(:binary).map(&:tag)
      end

      def unaries
        with_type(:unary).map(&:tag)
      end

      private

      def with_type(type)
        registry.values.select { |op| op < self && op.type == type }
      end

      def registry
        @@registry ||= {}
      end
    end
  end
end

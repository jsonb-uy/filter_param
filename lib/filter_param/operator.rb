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

      private

      def registry
        @registry ||= {}
      end
    end

    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

    def negated_sql(*operands)
      "NOT #{sql(*operands)}"
    end

    private

    def sql_quote(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end

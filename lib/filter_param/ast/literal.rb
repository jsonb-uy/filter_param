module FilterParam
  module AST
    class Literal < Node
      attr_reader :value

      def initialize(value = nil)
        @value = value
      end

      def type_cast(type)
        return self if type.blank?

        cast_method = "to_#{type}"
        return send(cast_method) if respond_to?(cast_method, true)

        raise InvalidLiteral.new("'#{value}' is not a #{type}")
      end

      private

      def visit_method
        :visit_literal
      end
    end
  end
end

module FilterParam
  module AST
    class Literal < Node
      attr_accessor :value

      def initialize(value = nil)
        @value = value
      end

      def type_cast(type)
        return self if type.blank?

        cast_method = "to_#{type}"
        return send(cast_method) if respond_to?(cast_method, true)

        raise InvalidLiteral.new("Cannot cast '#{value}' to #{type}")
      end

      private

      def visit_method
        :visit_literal
      end
    end
  end
end

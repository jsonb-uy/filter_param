module FilterParam
  module AST
    class AttributeExpression < BinaryExpression
      def initialize(operator, attribute, literal)
        super(operator, attribute, literal)

        validate_value!(value)
      end

      def attribute
        left
      end

      def literal
        right
      end

      private

      def literal_allowed?(literal)
        false
      end

      def validate_literal!(literal)
        return if literal_allowed?(literal)

        value = literal.value.present? ? "(#{literal.value})" : ""
        raise FilterParam::InvalidLiteral.new(
          "Unexpected #{literal.type} value#{value} for operator '#{op}'."
        )
      end
    end
  end
end

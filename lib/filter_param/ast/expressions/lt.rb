module FilterParam
  module AST
    class Lt < AttributeExpression
      private

      def literal_allowed?(literal)
        literal.is_a?(Literals::Integer) || literal.is_a?(Literals::Date)
      end
    end
  end
end

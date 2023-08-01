module FilterParam
  module AST
    class Ew < AttributeExpression
      private

      def literal_allowed?(literal)
        literal.is_a?(Literals::String)
      end
    end
  end
end

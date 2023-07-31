module FilterParam
  module AST
    class Neq < AttributeExpression
      private

      def literal_allowed?(_)
        true
      end
    end
  end
end

module FilterParam
  module AST
    class Eq < AttributeExpression
      private

      def literal_allowed?(_)
        true
      end
    end
  end
end

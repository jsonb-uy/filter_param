module FilterParam
  module AST
    class Group < Expressions::UnaryExpression
      attr_reader :expression

      def initialize(expression)
        super(:group, expression)

        @expression = expression
      end
    end
  end
end

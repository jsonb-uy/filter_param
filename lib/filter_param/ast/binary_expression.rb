module FilterParam
  module AST
    class BinaryExpression < Node
      attr_reader :left, :op, :right

      def initialize(operator, left, right)
        super()

        @op = operator.to_sym
        @left = left
        @right = right
      end
    end
  end
end

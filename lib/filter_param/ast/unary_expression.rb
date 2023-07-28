module FilterParam
  module AST
    class UnaryExpression < Node
      attr_reader :op, :exp

      def initialize(operator, exp)
        super()

        @op = operator.to_sym
        @exp = exp
      end
    end
  end
end

module FilterParam
  module Filter
    module AST
      class UnaryExpression < Node
        attr_reader :exp, :op

        def initialize(exp, operator)
          super()

          @exp = exp
          @op = operator.to_s
        end
      end
    end
  end
end
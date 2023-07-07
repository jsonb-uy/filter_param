module FilterParam
  module Filter
    module AST
      module Nodes
        class UnaryExpression < Node
          attr_reader :exp, :op

          def initialize(exp, operator)
            super()

            @exp = exp
            @op = operator.to_sym

            @children = [exp]
          end
        end
      end
    end
  end
end

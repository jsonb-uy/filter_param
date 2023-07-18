module FilterParam
  module Filter
    module AST
      module Nodes
        module Expressions
          class Unary < Node
            attr_reader :exp, :op

            def initialize(exp, operator)
              super()

              @exp = exp
              @op = operator.to_sym
            end
          end
        end
      end
    end
  end
end

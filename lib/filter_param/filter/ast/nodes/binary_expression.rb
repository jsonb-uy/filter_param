module FilterParam
  module Filter
    module AST
      module Nodes
        class BinaryExpression < Node
          attr_reader :left, :op, :right

          def initialize(left, operator, right)
            super()

            @left = left
            @op = operator.to_sym
            @right = right

            @children = [left, right]
          end
        end
      end
    end
  end
end

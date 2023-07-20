module FilterParam
  module Filter
    module AST
      module Nodes
        class BinaryExpression < Node
          attr_reader :left, :op, :right

          def initialize(operator, left, right)
            super()

            @op = operator.to_sym
            @left = left
            @right = right
          end

          # private

          # def raise_invalid_value!
          #   raise FilterParam::InvalidFilterValue.new("Filter value for `#{left.name}` cannot be a #{right.type}.")
          # end
        end
      end
    end
  end
end

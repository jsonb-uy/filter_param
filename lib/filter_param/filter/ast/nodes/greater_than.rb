module FilterParam
  module Filter
    module AST
      module Nodes
        class GreaterThan < BinaryExpression
          def initialize(left, operator, right)
            super

            raise_invalid_value! if %i[null boolean].include?(right.type)
          end
        end
      end
    end
  end
end

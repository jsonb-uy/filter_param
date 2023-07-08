module FilterParam
  module Filter
    module AST
      module Nodes
        class IntLiteral < Literal
          attr_reader :value

          def initialize(value = nil)
            super(value)

            @value = Integer(value)
          end
        end
      end
    end
  end
end

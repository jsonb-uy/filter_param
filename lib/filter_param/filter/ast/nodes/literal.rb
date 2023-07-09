module FilterParam
  module Filter
    module AST
      module Nodes
        class Literal < Node
          attr_reader :value

          def initialize(value)
            @value = value.to_s
          end
        end
      end
    end
  end
end

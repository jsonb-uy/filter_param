module FilterParam
  module Filter
    module AST
      module Nodes
        class Group < Node
          attr_reader :exp

          def initialize(exp)
            super()

            @exp = exp

            @children = [exp]
          end
        end
      end
    end
  end
end

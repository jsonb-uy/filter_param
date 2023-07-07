module FilterParam
  module Filter
    module AST
      module Nodes
        class Field < Node
          attr_reader :name

          def initialize(name)
            super()

            @name = name.to_s
          end

          alias to_s name
        end
      end
    end
  end
end

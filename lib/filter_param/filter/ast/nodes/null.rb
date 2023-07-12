module FilterParam
  module Filter
    module AST
      module Nodes
        class Null < Literal
          include Singleton

          def initialize
            @type = :null
            @value = nil
          end
        end
      end
    end
  end
end

module FilterParam
  module Filter
    module AST
      module Nodes
        class Literal < Node
          attr_reader :value

          def initialize(value)
            @value = value
          end

          def self.type_for(type_symbol)
            "#{type_symbol.to_s.camelize}Literal".safe_constantize
          end
        end
      end
    end
  end
end

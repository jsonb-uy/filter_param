module FilterParam
  module Filter
    module AST
      module Nodes
        class Literal < Node
          attr_accessor :type
          attr_reader :value

          def initialize(value, type)
            @type = type
            self.value = value
          end

          def value=(value)
            @value = value.to_s
          end
        end
      end
    end
  end
end

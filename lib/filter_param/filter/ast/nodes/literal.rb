module FilterParam
  module Filter
    module AST
      module Nodes
        class Literal < Node
          attr_reader :value, :data_type

          def initialize(value = nil, data_type = :string)
            super()

            @value = value
            @data_type = data_type
          end

          def to_s
            value.to_s
          end
        end
      end
    end
  end
end
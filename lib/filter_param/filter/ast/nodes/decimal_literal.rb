module FilterParam
  module Filter
    module AST
      module Nodes
        class DecimalLiteral < Literal
          attr_reader :value

          def initialize(value = nil)
            @value = BigDecimal(value.to_s)
          end
        end
      end
    end
  end
end

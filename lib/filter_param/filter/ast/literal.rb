module FilterParam
  module Filter
    module AST
      class Literal < Node
        attr_reader :value

        def initialize(value = nil)
          super()

          @value = value
        end
      end
    end
  end
end
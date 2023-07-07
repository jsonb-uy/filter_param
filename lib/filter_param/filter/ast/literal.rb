module FilterParam
  module Filter
    module AST
      class Literal < Node
        attr_reader :value, :data_type

        def initialize(value = nil, data_type = :string)
          super()

          @value = value
          @data_type = data_type
        end
      end
    end
  end
end

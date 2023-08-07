module FilterParam
  module AST
    class Attribute < Node
      attr_reader :name

      def initialize(name)
        super()

        @name = name
      end

      alias to_s name
    end
  end
end

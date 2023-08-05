module FilterParam
  module AST
    class Field < Node
      attr_reader :name, :type

      def initialize(name, type)
        super()

        @name = name.to_s
        @type = type
      end

      alias to_s name
    end
  end
end

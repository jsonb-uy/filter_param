module FilterParam
  module AST
    class Field < Node
      attr_reader :name, :type, :actual_name

      def initialize(type, name, actual_name = nil)
        super()

        @type = type
        @name = name
        @actual_name = actual_name.presence || name
      end

      alias to_s name
    end
  end
end

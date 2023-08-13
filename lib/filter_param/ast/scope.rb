module FilterParam
  module AST
    class Scope < Node
      attr_reader :name, :args

      def initialize(name, args)
        @name = name.to_s
        @args = args
      end
    end
  end
end

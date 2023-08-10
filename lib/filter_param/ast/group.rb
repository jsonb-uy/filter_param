module FilterParam
  module AST
    class Group < Node
      attr_reader :expression

      def initialize(expression)
        @expression = expression
      end
    end
  end
end

module FilterParam
  module AST
    class Group < Node
      attr_reader :exp

      def initialize(exp)
        super()

        @exp = exp
      end
    end
  end
end

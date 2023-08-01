module FilterParam
  module AST
    class Group < Node
      attr_reader :exp

      def initialize(exp)
        super()

        @exp = exp
      end

      def to_sql(context)
        "(#{exp.to_sql(context)})"
      end
    end
  end
end

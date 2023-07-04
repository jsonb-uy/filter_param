module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile(expression)
        ast = ASTTransformer.new.apply(Parser.new.parse(expression))

        ast
      end

      private

      attr_reader :definition
    end
  end
end

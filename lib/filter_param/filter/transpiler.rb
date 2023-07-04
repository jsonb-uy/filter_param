module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile(expression)
        ast = ASTTransformer.new.apply(Parser.new.parse(expression))

        evaluate(ast)
      end

      def visit_group_expression(group_exp)
        "(#{evaluate(group_exp.exp)})"
      end

      def visit_unary_expression(unary_exp)
        op = unary_exp.op
        exp = evaluate(unary_exp.exp)
        return "#{exp} IS NOT NULL" if op == "pr"

        "#{op} #{exp}"
      end

      def visit_identifier(identifier)
        identifier.name
      end

      private

      attr_reader :definition

      def evaluate(node)
        node.accept(self)
      end
    end
  end
end

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

      def visit_group(group)
        "(#{evaluate(group.exp)})"
      end

      def visit_unary_expression(unary_exp)
        op = unary_exp.op
        exp = evaluate(unary_exp.exp)
        return "#{exp} IS NOT NULL" if op == "pr"

        "#{op} #{exp}"
      end

      def visit_binary_expression(unary_exp)
        op = unary_exp.op
        exp = evaluate(unary_exp.exp)
        return "#{exp} IS NOT NULL" if op == "pr"

        "#{op} #{exp}"
      end

      def visit_identifier(identifier)
        return identifier.name if identifier_whitelisted?(identifier)

        raise UnsupportedFilterField.new("Unsupported filter field: '#{identifier}'")
      end

      private

      attr_reader :definition

      def evaluate(node)
        node.accept(self)
      end

      def identifier_whitelisted?(identifier)
        definition.fields_hash.key? identifier.name
      end
    end
  end
end

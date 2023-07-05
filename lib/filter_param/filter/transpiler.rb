module FilterParam
  module Filter
    class Transpiler
      OPERATIONS = {
        "and" => "AND",
        "or" => "OR",
        "not" => "NOT",
        "eq" => "=",
        "neq" => "!=",
        "le" => "<=",
        "lt" => "<",
        "ge" => ">=",
        "gt" => ">",
        "pr" => "IS NOT NULL"
      }.freeze

      def initialize(definition)
        @definition = definition
      end

      def transpile(expression)
        parse_tree = Parser.new.parse(expression)
        ast = ASTTransformer.new.apply(parse_tree)

        evaluate ast
      end

      def visit_group(group)
        "(#{evaluate(group.exp)})"
      end

      def visit_identifier(identifier)
        return identifier.name if identifier_whitelisted?(identifier)

        raise UnsupportedFilterField.new("Unsupported filter field: '#{identifier}'")
      end

      def visit_literal(literal)
        literal.value
      end

      def visit_unary_expression(unary_exp)
        op = unary_exp.op
        exp = evaluate(unary_exp.exp)
        return "#{exp} #{OPERATIONS[op]}" if op == "pr"

        "#{OPERATIONS[op]} #{exp}"
      end

      def visit_binary_expression(binary_exp)
        op = binary_exp.op
        translated_op = OPERATIONS[op]
        left = evaluate(binary_exp.left)
        right = evaluate(binary_exp.right)

        "#{left} #{translated_op} #{right}" # if translated_op.present?

        # case op
        # when "eq_ci"
        #   "lower(#{left}) = lower(#{right})"
        # when "sw"
        #   "#{left} like #{right}"
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

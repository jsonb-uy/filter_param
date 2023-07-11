require_relative "backend/postgresql"

module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile!(expression)
        return nil if expression.blank?

        parse_tree = Parser.new.parse(expression, reporter: Parslet::ErrorReporter::Deepest.new)
        ast = AST::Transformer.new.apply(parse_tree, definition: definition)

        permission_checker.visit_node(ast)
                          .then { |ast| backend.visit_node(ast) }
      end

      private

      attr_reader :definition

      def permission_checker
        AST::FieldPermissionChecker.new(definition)
      end

      def backend
        Backend::Postgresql.new(definition)
      end
    end
  end
end

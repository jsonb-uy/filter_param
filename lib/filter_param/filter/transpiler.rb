require_relative "backend/postgresql"

module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile!(expression)
        return nil if expression.blank?

        expression_to_ast!(expression).then { |ast| check_field_permissions!(ast) }
                                      .then { |ast| check_null_fields!(ast) }
                                      .then { |ast| transpile_to_sql!(ast) }
      end

      private

      attr_reader :definition

      def expression_to_ast!(expression)
        parse_tree = Parser.new.parse(expression, reporter: Parslet::ErrorReporter::Deepest.new)

        AST::Transformer.new.apply(parse_tree, definition: definition)
      end

      def check_field_permissions!(ast)
        AST::FieldPermissionChecker.new(definition).visit_node(ast)
      end

      def check_null_fields!(ast)
        AST::FieldNullValueChecker.new(definition).visit_node(ast)
      end

      def transpile_to_sql!(ast)
        Backend::Postgresql.new(definition).visit_node(ast)
      end
    end
  end
end

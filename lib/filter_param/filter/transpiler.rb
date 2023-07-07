require_relative "backends/postgresql"
require_relative "validators/field_permission_validator"
require_relative "validators/field_value_type_validator"

module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile!(expression)
        return nil if expression.blank?

        parse_tree = Parser.new.parse(expression, reporter: Parslet::ErrorReporter::Deepest.new)
        ast = AstTransformer.new.apply(parse_tree, definition: definition)

        field_validator.validate!(ast)
                       .then { |ast| field_value_type_validator.validate!(ast) }
                       .then { |ast| backend.evaluate(ast) }
      end

      private

      attr_reader :definition

      def field_validator
        Validators::FieldPermissionValidator.new(definition)
      end

      def field_value_type_validator
        Validators::FieldValueTypeValidator.new(definition)
      end

      def backend
        Backends::Postgresql.new(definition)
      end
    end
  end
end

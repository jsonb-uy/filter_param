require_relative "backend/postgresql"

module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile!(expression)
        return nil if expression.blank?

        parse_tree = Parser.new.parse(expression)
        ast = AstTransformer.new.apply(parse_tree)
        validate! ast
        backend.evaluate ast
      rescue Parslet::ParseFailed => e
        puts "e.message ====> #{e.message}"
        raise ParseError.new(e.message)
      end

      private

      attr_reader :definition

      def identifier_whitelisted?(identifier)
        definition.fields_hash.key? identifier.name
      end

      def validate!(node)
        if node.is_a?(AST::Identifier) && !identifier_whitelisted?(node)
          raise UnpermittedField.new("Unpermitted filter field: '#{node.name}'")
        end

        node.children&.each do |child|
          validate!(child)
        end
      end

      def backend
        Backend::Postgresql.new(definition)
      end
    end
  end
end

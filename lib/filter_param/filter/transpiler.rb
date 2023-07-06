require_relative "backend/postgresql"

module FilterParam
  module Filter
    class Transpiler
      def initialize(definition)
        @definition = definition
      end

      def transpile!(expression)
        return nil if expression.blank?

        parse_tree = Parser.new.parse(expression,
          reporter: Parslet::ErrorReporter::Deepest.new
        )
        ast = AstTransformer.new.apply(parse_tree)
        validate! ast
        backend.evaluate ast
      rescue Parslet::ParseFailed => e
        parse_cause = e.parse_failure_cause.children.last

        raise parse_error(parse_cause)
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

      def parse_error(parse_cause)
        parse_cause = parse_cause.to_s
        invalid_expression = "Filter expression syntax error."

        if parse_cause.start_with?("Expected one of")
          parse_cause = invalid_expression
        else
          unexpected_token = "Unexpected token"

          parse_cause.sub!("Don't know what to do with", unexpected_token)
          parse_cause.sub!(/(Failed to match).*.(at line 1)/, "#{unexpected_token} at")
          parse_cause.sub!(/(at line 1)/, "at")
        end

        puts "Error: #{parse_cause}"

        ParseError.new(parse_cause)
      end

      def backend
        Backend::Postgresql.new(definition)
      end
    end
  end
end

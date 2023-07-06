module FilterParam
  module Filter
    module Backend
      class Base
        OPS_MAP = {
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

        def visit_group(group)
          "(#{evaluate(group.exp)})"
        end

        def visit_identifier(identifier)
          field_options = definition.field_options(identifier.name)
          return identifier if field_options.nil?

          field_options[:rename].presence || identifier
        end

        def visit_literal(literal)
          literal.value
        end

        def evaluate(node)
          node.accept(self)
        end

        private

        attr_reader :definition

        def quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

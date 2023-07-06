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

        def visit_group(group)
          "(#{evaluate(group.exp)})"
        end

        def visit_identifier(identifier)
          return identifier.name
        end

        def visit_literal(literal)
          literal.value
        end

        def evaluate(node)
          node.accept(self)
        end

        private

        def quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

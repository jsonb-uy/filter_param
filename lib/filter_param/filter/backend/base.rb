module FilterParam
  module Filter
    module Backend
      class Base
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
      end
    end
  end
end

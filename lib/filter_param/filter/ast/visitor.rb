module FilterParam
  module Filter
    module AST
      class Visitor
        def initialize(definition)
          @definition = definition
        end

        def visit_group(group)
          visit_node(group.exp)
        end

        def visit_field(field)
          field
        end

        def visit_literal(literal)
          literal
        end

        def visit_null(null)
          null
        end

        def visit_binary_expression(binary_exp)
          visit_node(binary_exp.left)
          visit_node(binary_exp.right)

          binary_exp
        end

        def visit_unary_expression(unary_exp)
          visit_node(unary_exp.exp)

          unary_exp
        end

        def visit_node(node)
          node.accept(self)
        end

        private

        attr_reader :definition
      end
    end
  end
end

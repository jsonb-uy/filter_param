module FilterParam
  module Filter
    module AST
      class Visitor
        def initialize(definition)
          @definition = definition
        end

        def visit_group(group)
          evaluate(group.exp)
        end

        def visit_field(field)
          field
        end

        def visit_literal(literal)
          literal
        end

        def visit_binary_expression(binary_exp)
          evaluate(binary_exp.left)
          evaluate(binary_exp.right)

          binary_exp
        end

        def visit_unary_expression(unary_exp)
          evaluate(unary_exp.exp)

          unary_exp
        end

        def evaluate(node)
          node.accept(self)
        end

        private

        attr_reader :definition
      end
    end
  end
end

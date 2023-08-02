module FilterParam
  class Visitor
    def initialize(definition)
      @definition = definition
    end

    def visit_group(group)
      visit_node(group.exp)

      group
    end

    def visit_field(field)
      field
    end

    def visit_literal(literal)
      literal
    end

    def visit_binary_expression(expression)
      visit_node(expression.left_operand)
      visit_node(expression.right_operand)

      expression
    end

    def visit_unary_expression(expression)
      visit_node(expression.operand)

      expression
    end

    def visit_node(node)
      node.accept(self)
    end

    private

    attr_reader :definition
  end
end

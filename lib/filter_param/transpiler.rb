module FilterParam
  class Transpiler < Visitor
    def transpile!(expression)
      return nil if expression.blank?

      ast = expression_to_ast!(expression)
      visit_node(ast)
    end

    def visit_group(group)
      "(#{visit_node(group.expression)})"
    end

    def visit_attribute(attribute)
      declared_field(attribute.name).rename.presence || attribute.name
    end

    def visit_literal(literal)
      literal.value
    end

    def visit_unary_expression(expression)
      operator_symbol = expression.operator_symbol
      operand = visit_node(expression.operand)

      evaluate(operator_symbol, operand)
    end

    def visit_binary_expression(expression)
      operator_symbol = expression.operator_symbol
      left_operand = visit_node(expression.left_operand)
      right_operand = if expression.comparison?
                        literal = expression.right_operand
                        field_value(left_operand, visit_node(literal))
                      else
                        visit_node(expression.right_operand)
                      end

      evaluate(operator_symbol, left_operand, right_operand)
    end

    private

    def evaluate(operator, *operands)
      send("evaluate_#{operator}", *operands)
    end

    def evaluate_not(expression)
      
      operator = expression.try(:operator)
      inverse_operators = { eq: :neq, neq: :eq, pr: :not_pr }
      inverse_operator = inverse_operators[operator]
      return "NOT #{visit_node(expression)}" unless inverse_operator

      return evaluate(inverse_operator, expression.exp) if operator == :pr

      field = visit_node(expression.field)
      literal = visit_node(expression.literal)
      evaluate(inverse_operator, field, literal)
    end

    def evaluate_pr(field)
      field_name = visit_node(field)
      return "#{field_name} IS NOT NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NOT NULL AND TRIM(#{field_name}) != '')"
    end

    def evaluate_not_pr(field)
      field_name = visit_node(field)
      return "#{field_name} IS NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NULL OR TRIM(#{field_name}) = '')"
    end

    def evaluate_and(left, right)
      "#{left} AND #{right}"
    end

    def evaluate_or(left, right)
      "#{left} OR #{right}"
    end

    def evaluate_eq(field, value)
      return "#{field} IS NULL" if value.nil?

      "#{field} = #{quote(value)}"
    end

    def evaluate_eq_ci(field, value)
      "lower(#{field}) = #{quote(value.downcase)}"
    end

    def evaluate_neq(field, value)
      return "#{field} IS NOT NULL" if value.nil?

      "#{field} != #{quote(value)}"
    end

    def evaluate_lt(field, value)
      "#{field} < #{quote(value)}"
    end

    def evaluate_le(field, value)
      "#{field} <= #{quote(value)}"
    end

    def evaluate_gt(field, value)
      "#{field} > #{quote(value)}"
    end

    def evaluate_ge(field, value)
      "#{field} >= #{quote(value)}"
    end

    def evaluate_sw(field, value)
      pattern = "#{value}%"

      "#{field} LIKE #{quote(pattern)}"
    end

    def evaluate_ew(field, value)
      pattern = "%#{value}"

      "#{field} LIKE #{quote(pattern)}"
    end

    def evaluate_co(field, value)
      pattern = "%#{value}%"

      "#{field} LIKE #{quote(pattern)}"
    end

    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end

    def expression_to_ast!(expression)
      parse_tree = Parser.new.parse(expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end
  end
end

module FilterParam
  class Transpiler < Visitor
    def transpile!(string_expression)
      return nil if string_expression.blank?

      ast_root = ast(string_expression)
      visit_node(ast_root)
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
      operator = expression.operator
      operand = visit_node(expression.operand)

      transpile_expression(operator, operand)
    end

    def visit_binary_expression(expression)
      operator = expression.operator
      left_operand = visit_node(expression.left_operand)
      right_operand = if expression.right_operand.is_a?(Literal)
                        attribute_name = left_operand
                        literal = visit_node(expression.right_operand)

                        transform_field_value(attribute_name, literal)
                      else
                        visit_node(right_operand)
                      end

      transpile_expression(operator, left_operand, right_operand)
    end

    private

    def ast(string_expression)
      parse_tree = Parser.new.parse(expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end

    def transpile_expression(operator, *operands)
      send("transpile_#{operator}", *operands)
    end

    def transpile_not(expression)
      operator = expression.try(:operator)
      inverse_operators = { eq: :neq, neq: :eq, pr: :not_pr }
      inverse_operator = inverse_operators[operator]
      return "NOT #{visit_node(expression)}" unless inverse_operator

      return transpile_expression(inverse_operator, expression.exp) if operator == :pr

      field = visit_node(expression.field)
      literal = visit_node(expression.literal)
      transpile_expression(inverse_operator, field, literal)
    end

    def transpile_pr(field)
      field_name = visit_node(field)
      return "#{field_name} IS NOT NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NOT NULL AND TRIM(#{field_name}) != '')"
    end

    def transpile_not_pr(field)
      field_name = visit_node(field)
      return "#{field_name} IS NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NULL OR TRIM(#{field_name}) = '')"
    end

    def transpile_and(left, right)
      "#{left} AND #{right}"
    end

    def transpile_or(left, right)
      "#{left} OR #{right}"
    end

    def transpile_eq(field, value)
      return "#{field} IS NULL" if value.nil?

      "#{field} = #{quote(value)}"
    end

    def transpile_eq_ci(field, value)
      "lower(#{field}) = #{quote(value.downcase)}"
    end

    def transpile_neq(field, value)
      return "#{field} IS NOT NULL" if value.nil?

      "#{field} != #{quote(value)}"
    end

    def transpile_lt(field, value)
      "#{field} < #{quote(value)}"
    end

    def transpile_le(field, value)
      "#{field} <= #{quote(value)}"
    end

    def transpile_gt(field, value)
      "#{field} > #{quote(value)}"
    end

    def transpile_ge(field, value)
      "#{field} >= #{quote(value)}"
    end

    def transpile_sw(field, value)
      pattern = "#{value}%"

      "#{field} LIKE #{quote(pattern)}"
    end

    def transpile_ew(field, value)
      pattern = "%#{value}"

      "#{field} LIKE #{quote(pattern)}"
    end

    def transpile_co(field, value)
      pattern = "%#{value}%"

      "#{field} LIKE #{quote(pattern)}"
    end

    def quote(value)
      ActiveRecord::Base.connection.quote(value)
    end
  end
end

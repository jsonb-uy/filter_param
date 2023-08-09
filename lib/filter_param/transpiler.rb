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
      operator_symbol = expression.operator
      operand = expression.operand
      return transpile_negated_expression(operand) if operator_symbol == :not

      operand = visit_node(operand)
      Operator.for(operator_symbol).sql(operand)
    end

    def visit_binary_expression(expression)
      operator_symbol = expression.operator
      left_operand = visit_node(expression.left_operand)
      right_operand = if expression.right_operand.is_a?(Literal)
                        attribute_name = left_operand
                        literal = visit_node(expression.right_operand)

                        transform_field_value(attribute_name, literal)
                      else
                        visit_node(right_operand)
                      end

      Operator.for(operator_symbol).sql(left_operand, right_operand)
    end

    private

    def ast(string_expression)
      parse_tree = Parser.new.parse(string_expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end

    def transpile_not_expression(expression)
      operands = expression.operands.map { |operand| visit_node(operand) }

      Operator.for(:not).sql(expression.operator, *operands)
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

    def transpile_eq_ci(field, value)
      "lower(#{field}) = #{quote(value.downcase)}"
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
  end
end

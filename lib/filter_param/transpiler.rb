module FilterParam
  class Transpiler
    def initialize(definition)
      @definition = definition
    end

    def transpile!(string_expression)
      return nil if string_expression.blank?

      ast_root = ast(string_expression)
      visit(ast_root)
    end

    private

    attr_reader :definition

    def declared_field(field_name)
      definition.find_field!(field_name)
    end

    def transform_field_value(field_name, value)
      declared_field(field_name).transform_value(value)
    end

    def visit(node)
      node.accept(self)
    end

    def visit_group(group)
      "(#{visit(group.expression)})"
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

      operand = visit(operand)
      Operator.for(operator_symbol).sql(operand)
    end

    def visit_binary_expression(expression)
      operator_symbol = expression.operator
      operator = Operator.for(operator_symbol)

      if operator < Operators::AttributeFilterOperator
        attribute_name = visit(expression.left_operand)
        declared_type = declared_field(attribute_name).type
        literal = expression.right_operand.type_cast(declared_type)

        value = transform_field_value(attribute_name, visit(literal))
        return operator.sql(attribute_name, value)
      end

      operator.sql(visit(expression.left_operand),
                   visit(expression.right_operand))
    end

    def ast(string_expression)
      parse_tree = Parser.new.parse(string_expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end

    def transpile_not_expression(expression)
      operands = expression.operands.map { |operand| visit(operand) }

      Operator.for(:not).sql(expression.operator, *operands)
    end

    def transpile_pr(field)
      field_name = visit(field)
      return "#{field_name} IS NOT NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NOT NULL AND TRIM(#{field_name}) != '')"
    end

    def transpile_not_pr(field)
      field_name = visit(field)
      return "#{field_name} IS NULL" unless field_data_type(field_name) == :string

      "(#{field_name} IS NULL OR TRIM(#{field_name}) = '')"
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

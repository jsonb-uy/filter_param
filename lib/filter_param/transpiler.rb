module FilterParam
  class Transpiler < Visitor
    def transpile!(expression)
      return nil if expression.blank?

      expression_to_ast!(expression)
        .then { |ast| check_field_permissions!(ast) }
        .then { |ast| visit_node(ast) }
    end

    def visit_group(group)
      "(#{visit_node(group.exp)})"
    end

    def visit_field(field)
      options = field_options(field.name)
      return field if options.nil?

      options[:rename].presence || field.name
    end

    def visit_literal(literal)
      literal.value
    end

    def visit_unary_expression(unary_exp)
      op = unary_exp.op

      evaluate(op, unary_exp.exp)
    end

    def visit_comparison(comparison)
      op = comparison.op
      actual_field_name = comparison.field.name
      aliased_field_name = visit_node(comparison.field)
      literal_value = field_value(actual_field_name, visit_node(comparison.literal))

      evaluate(op, aliased_field_name, literal_value)
    end

    def visit_binary_expression(expression)
      op = expression.op
      left = visit_node(expression.left)
      right = visit_node(expression.right)

      evaluate(op, left, right)
    end

    private

    def field_data_type(field_name)
      definition.field_type(field_name)
    end

    def field_options(field_name)
      definition.field_options(field_name)
    end

    def field_value(field_name, literal_value)
      transform_logic = field_options(field_name)[:value]
      return literal_value if transform_logic.nil?

      transform_logic.call(literal_value)
    end

    def evaluate(operator, *operands)
      send("evaluate_#{operator}", *operands)
    end

    def evaluate_not(expression)
      operator = expression.try(:op)
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

      Transformer.new.apply(parse_tree, definition: definition)
    end

    def check_field_permissions!(ast)
      FieldNodeValidator.new(definition).visit_node(ast)
    end
  end
end

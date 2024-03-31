module FilterParam
  class Transpiler
    def initialize(ar_relation, definition)
      @ar_relation = ar_relation
      @definition = definition
    end

    def transpile!(string_expression)
      return nil if string_expression.blank?

      ast_root = parse(string_expression)

      visit(ast_root)
    end

    private

    attr_reader :ar_relation, :definition

    def ar_model
      @ar_relation.model
    end

    def parse(string_expression)
      parse_tree = Parser.new.parse(string_expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end

    def field_for_name(name)
      definition.find_field!(name)
    end

    def visit(node)
      return node unless node.respond_to?(:accept)

      node.accept(self)
    end

    def visit_group(group)
      expression = visit(group.expression)

      Operator.for(:group).sql(expression)
    end

    def visit_scope(scope)
      actual_scope_name = definition.find_scope!(scope.name)
                                    .actual_name
      scope_args = scope.args.map { |arg| visit(arg) }

      scope_sql = ar_model.send(actual_scope_name, *scope_args)
                          .select(ar_model.primary_key)
                          .to_sql

      "(#{ar_model.primary_key} IN (#{scope_sql}))"
    end

    def visit_attribute(attribute)
      field_for_name(attribute.name)
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

      if operator < Operators::FieldFilterOperator
        field = visit(expression.left_operand)
        literal = expression.right_operand
        literal.value = field.transform_value(literal.value)

        return operator.sql(field, literal.type_cast(field.type))
      end

      operator.sql(visit(expression.left_operand),
                   visit(expression.right_operand))
    end

    def transpile_negated_expression(expression)
      operator_tag = expression.operator
      operator = Operator.for(operator_tag)
      not_operator = Operator.for(:not)

      if operator < Operators::FieldFilterOperator
        # TODO: refactor
        if operator.type == :binary
          field = visit(expression.left_operand)
          literal = expression.right_operand
          literal.value = field.transform_value(literal.value)

          return not_operator.sql(operator_tag, field, literal.type_cast(field.type))
        else
          return not_operator.sql(operator_tag, visit(expression.operand))
        end
      end

      operands = expression.operands.map { |operand| visit(operand) }

      not_operator.sql(operator_tag, *operands)
    end
  end
end

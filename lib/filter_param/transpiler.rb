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

    def parse(string_expression)
      parse_tree = Parser.new.parse(string_expression, reporter: Parslet::ErrorReporter::Deepest.new)

      Transformer.new.apply(parse_tree)
    end

    def field(name)
      definition.find_field!(name)
    end

    def visit(node)
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

      scope_sql = ar_relation.model
                             .send(actual_scope_name, *scope_args)
                             .where_clause
                             .ast
                             .to_sql

      "(#{scope_sql})"
    end

    def visit_attribute(attribute)
      field(attribute.name)
    end

    def visit_literal(literal)
      literal
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
      operands = expression.operands.map { |operand| visit(operand) }

      Operator.for(:not).sql(expression.operator, *operands)
    end
  end
end

module FilterParam
  module Filter
    module Backend
      class Sql < Filter::AST::Visitor
        def visit_group(group)
          "(#{visit_node(group.exp)})"
        end

        def visit_field(field)
          field_options = definition.field_options(field.name)
          return field if field_options.nil?

          field_options[:rename].presence || field.name
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
          field = visit_node(comparison.field)
          literal = visit_node(comparison.literal)

          evaluate(op, field, literal)
        end

        def visit_logical_expression(expression)
          op = expression.op
          left = visit_node(expression.left)
          right = visit_node(expression.right)

          evaluate(op, left, right)
        end

        private

        def data_type(field)
          definition.field_type(field)
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
          field = visit_node(field)
          return "#{field} IS NOT NULL" unless data_type(field) == :string

          "(#{field} IS NOT NULL AND TRIM(#{field}) != '')"
        end

        def evaluate_not_pr(field)
          field = visit_node(field)
          return "#{field} IS NULL" unless data_type(field) == :string

          "(#{field} IS NULL OR TRIM(#{field}) = '')"
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
      end
    end
  end
end

require_relative "base"

module FilterParam
  module Filter
    module Backend
      class Postgresql < Base
        def visit_unary_expression(unary_exp)
          op = unary_exp.op
          node = visit_node(unary_exp.exp)

          send("evaluate_#{op}", node)
        end

        def visit_comparison(comparison)
          op = comparison.op
          field = visit_node(comparison.field)
          literal = visit_node(comparison.literal)

          send("evaluate_#{op}", field, literal)
        end

        def visit_logical_expression(expression)
          op = expression.op
          left = visit_node(expression.left)
          right = visit_node(expression.right)

          send("evaluate_#{op}", left, right)
        end

        private

        def evaluate_not(expression)
          "NOT #{expression}"
        end

        def evaluate_pr(field)
          "#{field} IS NOT NULL"
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
      end
    end
  end
end

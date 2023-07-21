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

        def visit_binary_expression(binary_exp)
          op = binary_exp.op
          left = visit_node(binary_exp.left)
          right = visit_node(binary_exp.right)

          send("evaluate_#{op}", left, right.value)
        end

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

require_relative "base"

module FilterParam
  module Filter
    module Backend
      class Postgresql < Base
        OPERATORS = {
          and: proc { |left, right| "#{left} AND #{right}" },
          or: proc { |left, right| "#{left} OR #{right}" },
          not: proc { |exp| "NOT #{exp}" },
          eq: proc do |field, value|
                if value.nil?
                  "#{field} IS NULL"
                else
                  "#{field} = #{value}"
                end
              end,
          eq_ci: proc do |field, value|
                   "lower(#{field}) = #{value.downcase}"
                 end,
          neq: proc do |field, value|
                 if value.nil?
                   "#{field} IS NOT NULL"
                 else
                   "#{field} != #{value}"
                 end
               end,
          le: proc { |field, value| "#{field} <= #{value}" },
          lt: proc { |field, value| "#{field} < #{value}" },
          ge: proc { |field, value| "#{field} >= #{value}" },
          gt: proc { |field, value| "#{field} > #{value}" },
          pr: proc { |field| "#{field} IS NOT NULL" }
        }.freeze

        def visit_unary_expression(unary_exp)
          op = unary_exp.op
          node = visit_node(unary_exp.exp)

          OPERATORS[op].call(node)
        end

        def visit_binary_expression(binary_exp)
          op = binary_exp.op
          left = visit_node(binary_exp.left)
          right = visit_node(binary_exp.right)

          OPERATORS[op].call(left, right)
        end
      end
    end
  end
end

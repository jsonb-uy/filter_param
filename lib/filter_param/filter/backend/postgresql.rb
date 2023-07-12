require_relative "base"

module FilterParam
  module Filter
    module Backend
      class Postgresql < Base
        OPS_MAP = {
          and: ->(left, right) { "#{left} AND #{right}" },
          or: ->(left, right) { "#{left} OR #{right}" },
          not: ->(exp) { "NOT #{exp}" },
          eq: Proc.new do |field, value|
                if value.nil?
                  "#{field} IS NULL"
                else
                  "#{field} = #{value}"
                end
              end,
          neq: Proc.new do |field, value|
                if value.nil?
                  "#{field} IS NOT NULL"
                else
                  "#{field} != #{value}"
                end
              end,
          le: ->(field, value) { "#{field} <= #{value}" },
          lt: ->(field, value) { "#{field} < #{value}" },
          ge: ->(field, value) { "#{field} >= #{value}" },
          gt: ->(field, value) { "#{field} > #{value}" },
          pr: ->(field) { "#{field} IS NOT NULL" }
        }.freeze

        def visit_unary_expression(unary_exp)
          op = unary_exp.op
          node = visit_node(unary_exp.exp)

          OPS_MAP[op].call(node)
        end

        def visit_binary_expression(binary_exp)
          op = binary_exp.op
          left = visit_node(binary_exp.left)
          right = visit_node(binary_exp.right)

          OPS_MAP[op].call(left, right)
        end
      end
    end
  end
end

require_relative "base"

module FilterParam
  module Filter
    module Backend
      class Postgresql < Base
        def visit_unary_expression(unary_exp)
          op = unary_exp.op
          exp = evaluate(unary_exp.exp)
          return "#{exp} #{op}" if op == "pr"

          "#{op} #{exp}"
        end

        def visit_binary_expression(binary_exp)
          op = binary_exp.op
          translated_op = op
          left = evaluate(binary_exp.left)
          right = evaluate(binary_exp.right)

          "#{left} #{translated_op} #{right}" # if translated_op.present?

          # case op
          # when "eq_ci"
          #   "lower(#{left}) = lower(#{right})"
          # when "sw"
          #   "#{left} like #{right}"
        end
      end
    end
  end
end

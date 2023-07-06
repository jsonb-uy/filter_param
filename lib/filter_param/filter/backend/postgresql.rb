require_relative "base"

module FilterParam
  module Filter
    module Backend
      class Postgresql < Base
        def visit_unary_expression(unary_exp)
          op = unary_exp.op
          exp = evaluate(unary_exp.exp)
          return "#{exp} #{OPS_MAP[op]}" if op == "pr"

          "#{OPS_MAP[op]} #{exp}"
        end

        def visit_binary_expression(binary_exp)
          op = binary_exp.op
          left = evaluate(binary_exp.left)
          right = evaluate(binary_exp.right)

          case op
          when "and", "or"
            "#{left} #{OPS_MAP[op]} #{right}"
          when "eq_ci"
            "lower(#{left}) = #{quote(right.downcase)}"
          when "sw"
            value << "#{right}%"
            "#{left} like #{quote(value)}"
          when "ew"
            value << "%#{right}"
            "#{left} like #{quote(value)}"
          when "co"
            value << "%#{right}%"
            "#{left} like #{quote(value)}"
          else
            "#{left} #{OPS_MAP[op]} #{quote(right)}"
          end
        end
      end
    end
  end
end

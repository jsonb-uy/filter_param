module FilterParam
  module Filter
    module AST
      class FilterValueTypeChecker < AST::Visitor
        LITERAL_TYPE_CATEGORY_OPERATORS = {
          boolean: %i[eq neq],
          null: %i[eq neq],
          numeric: %i[eq neq gt ge lt le],
          string: %i[eq eq_ci neq gt ge lt le co sw ew],
          temporal: %i[eq neq gt ge lt le]
        }.freeze

        def visit_binary_expression(binary_exp)
          super(binary_exp)

          validate_value_type!(binary_exp)

          binary_exp
        end

        private

        def literal_allowed_for_operator?(literal, operator)
          type_category = literal.type_category

          operator.in?(LITERAL_TYPE_CATEGORY_OPERATORS[type_category])
        end

        def validate_value_type!(exp)
          op = exp.op
          literal = exp.right
          return if literal_allowed_for_operator?(literal, op)

          value = literal.value.present? ? "(#{literal.value})" : ""
          raise FilterParam::InvalidFilterValue.new(
            "Unexpected #{literal.type} value#{value} for operator '#{op}'."
          )
        end
      end
    end
  end
end

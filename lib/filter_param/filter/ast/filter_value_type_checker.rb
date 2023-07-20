module FilterParam
  module Filter
    module AST
      class FilterValueTypeChecker < AST::Visitor
        EQUALITY_CHECK_OPS = %i[eq neq].freeze
        EQUALITY_CHECK_RESTRICTED_LITERALS = %i[null boolean].freeze

        def visit_binary_expression(binary_exp)
          super(binary_exp)

          validate_value_type!(binary_exp)

          binary_exp
        end

        private

        def validate_value_type!(exp)
          field = exp.left
          op = exp.op
          literal = exp.right

          return unless EQUALITY_CHECK_RESTRICTED_LITERALS.include?(literal.type) &&
                        !EQUALITY_CHECK_OPS.include?(op)

          raise FilterParam::InvalidFilterValue.new("Unexpected #{literal.type} value for operator '#{op}'.")
        end
      end
    end
  end
end

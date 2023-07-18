module FilterParam
  module Filter
    module AST
      class FieldValueNullabilityChecker < AST::Visitor
        NULLABLE_OPERATIONS = %i[eq neq].freeze

        def visit_binary_expression(binary_exp)
          super(binary_exp)

          validate_value!(binary_exp)

          binary_exp
        end

        private

        def validate_value!(exp)
          field = exp.left
          op = exp.op
          literal = exp.right

          return unless literal.type == :null
          return if NULLABLE_OPERATIONS.include?(op)

          raise FilterParam::InvalidFilterValue.new("Filter value for `#{field}` must not be null.")
        end
      end
    end
  end
end

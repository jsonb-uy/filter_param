module FilterParam
  module Filter
    module AST
      class FieldNullValueChecker < AST::Visitor
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

          return unless %i[lt le gt ge sw ew co].include?(op)
          return unless literal.value.nil?

          raise FilterParam::InvalidFilterValue.new("Filter value for `#{field}` must not be null.")
        end
      end
    end
  end
end

module FilterParam
  module Filter
    module Validators
      class FieldValueTypeValidator < Validator
        TYPECHECKED_OPS = %i[eq neq eq_ci lt le gt ge sw ew co].freeze

        def visit_binary_expression(binary_exp)
          if typecheck?(binary_exp.op)
            field = binary_exp.left
            literal = binary_exp.right

            expected_type = definition.field_type(field.name)
            actual_type = literal.data_type

            if expected_type != actual_type
              raise TypeMismatch.new("Filter value '#{literal.value}'(#{actual_type}) must be #{expected_type}.")
            end
          end

          evaluate(binary_exp.left)
          evaluate(binary_exp.right)
        end

        private

        def typecheck?(operator)
          TYPECHECKED_OPS.include?(operator)
        end
      end
    end
  end
end

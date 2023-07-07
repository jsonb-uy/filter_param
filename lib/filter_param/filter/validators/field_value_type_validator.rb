module FilterParam
  module Filter
    module Validators
      class FieldValueTypeValidator < Validator
        TYPECHECKED_OPS = %i[eq neq eq_ci lt le gt ge sw ew co].freeze

        def visit_binary_expression(binary_exp)
          validate_type!(binary_exp.left, binary_exp.right) if typecheck?(binary_exp.op)

          evaluate(binary_exp.left)
          evaluate(binary_exp.right)

          binary_exp
        end

        private

        def validate_type!(field, value)
          expected_type = definition.field_type(field.name)
          actual_type = value.data_type

          return if expected_type == actual_type || actual_type == :null

          expected_phrase = case expected_type
                            when :date
                              "an ISO8601 date YYYY-MM-DD"
                            when :datetime
                              "an ISO8601 datetime in YYYY-MM-DDTHH:mm:ss.SSSZ"
                            else
                              expected_type.to_s
                            end

          error_message = "#{field} operand must be #{expected_phrase} (actual: '#{value}' [#{actual_type}])."

          raise TypeMismatch.new(error_message)
        end

        def typecheck?(operator)
          TYPECHECKED_OPS.include?(operator)
        end
      end
    end
  end
end

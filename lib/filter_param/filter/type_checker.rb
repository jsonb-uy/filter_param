module FilterParam
  module Filter
    class TypeChecker < AST::Visitor
      COMPARISON_OPS = %i[eq neq eq_ci lt le gt ge sw ew co].freeze

      def visit_binary_expression(binary_exp)
        super

        type_check!(binary_exp)
      end

      private

      def type_check!(comparison)
        op = comparison.op
        return comparison unless COMPARISON_OPS.include?(op)

        field = comparison.left
        value = comparison.right

        expected_type = definition.field_type(field.name)
        actual_type = value.type

        return comparison if expected_type == actual_type || actual_type == :null

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
    end
  end
end

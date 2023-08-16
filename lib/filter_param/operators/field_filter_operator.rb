module FilterParam
  module Operators
    class FieldFilterOperator < Operator
      class << self
        attr_reader :operand_data_types

        def operand_data_type(*data_types)
          @operand_data_types ||= Set.new
          @operand_data_types.merge(data_types)
          @operand_data_types
        end

        def sql(field, literal)
          validate_field!(field)
          validate_literal!(literal)
        end

        private

        def validate_field!(field)
          field.allow_operator?(tag)
        end

        def validate_literal!(literal)
          return if literal.nil?
          return if operand_data_types.nil?
          return if literal.data_type.in?(operand_data_types)

          raise FilterParam::InvalidLiteral.new(
            "Unexpected #{literal.data_type} operand for operator '#{tag}'."
          )
        end

        def sql_quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

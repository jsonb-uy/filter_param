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
          validate_operand!(literal)
        end

        private

        def validate_operand!(operand)
          return if operand.nil?
          return if operand_data_types.nil?
          return if operand.data_type.in?(operand_data_types)

          raise FilterParam::InvalidLiteral.new(
            "Unexpected #{operand.data_type} operand for operator '#{tag}'."
          )
        end

        def sql_quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

module FilterParam
  module Operators
    class FieldFilterOperator < Operator
      attr_reader :field_types

      def self.field_type(*data_types)
        @field_types ||= Set.new
        @field_types.merge(data_types)
        @field_types
      end

      def self.sql(field)
        validate_field!(field)
      end

      private

      def validate_field!(field)
        return if field_types.blank?
        return if field.type.in?(field_types)

        raise FilterParam::InvalidLiteral.new(
          "Unexpected #{field.type} operand for operator '#{tag}'."
        )
      end
    end
  end
end

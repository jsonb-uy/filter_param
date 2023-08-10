module FilterParam
  module Operators
    class FieldFilterOperator < Operator
      class << self
        attr_reader :literal_data_types

        def literal_data_type(*data_types)
          @literal_data_types ||= Set.new
          @literal_data_types.merge(data_types)
          @literal_data_types
        end

        def sql(field, literal)
          validate_literal!(literal)
        end

        private

        def validate_literal!(literal)
          return if literal.nil?
          return if literal_data_types.nil?
          return if literal.data_type.in?(literal_data_types)

          raise FilterParam::InvalidLiteral.new(
            "Unexpected #{literal.data_type} '#{literal.value}' for operator '#{tag}'."
          )
        end

        def sql_quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

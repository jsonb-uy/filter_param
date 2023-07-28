module FilterParam
  module AST
    class Comparison < Node
      LITERAL_TYPE_CATEGORY_OPERATORS = {
        boolean: %i[eq neq],
        null: %i[eq neq],
        numeric: %i[eq neq gt ge lt le],
        string: %i[eq eq_ci neq gt ge lt le co sw ew],
        temporal: %i[eq neq gt ge lt le]
      }.freeze

      attr_reader :op, :field, :literal

      def initialize(operator, field, literal)
        @op = operator.to_sym
        @field = field
        @literal = literal

        validate_literal_type!
      end

      private

      def literal_type_allowed?
        type_category = literal.type_category

        op.in?(LITERAL_TYPE_CATEGORY_OPERATORS[type_category])
      end

      def validate_literal_type!
        return if literal_type_allowed?

        value = literal.value.present? ? "(#{literal.value})" : ""
        raise FilterParam::InvalidFilterValue.new(
          "Unexpected #{literal.type} value#{value} for operator '#{op}'."
        )
      end
    end
  end
end

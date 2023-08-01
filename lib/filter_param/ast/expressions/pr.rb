module FilterParam
  module AST
    class Pr < UnaryExpression
      def attribute
        exp
      end

      def to_sql(context)
        attribute_name = attribute.to_sql(context)
        return "#{attribute_name} IS NOT NULL" unless string_attribute?

        "(#{attribute_name} IS NOT NULL AND TRIM(#{attribute_name}) != '')"
      end

      def to_inverse_sql(context)
        attribute_name = attribute.to_sql(context)
        return "#{attribute_name} IS NULL" unless string_attribute?

        "(#{attribute_name} IS NULL OR TRIM(#{attribute_name}) = '')"
      end

      private

      def string_attribute?
        context.field_type(attribute.name) == :string
      end
    end
  end
end

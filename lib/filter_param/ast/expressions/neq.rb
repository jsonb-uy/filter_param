module FilterParam
  module AST
    class Neq < AttributeExpression
      def to_sql(context)
        attribute_name = attribute.to_sql(context)
        return "#{attribute_name} IS NOT NULL" if literal.value.nil?

        "#{attribute_name} != #{literal.to_sql(context)}"
      end

      def to_inverse_sql(context)
        Eq.new(attribute, literal).to_sql(context)
      end

      private

      def literal_allowed?(_)
        true
      end
    end
  end
end

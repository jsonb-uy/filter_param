module FilterParam
  module AST
    class EqCi < AttributeExpression
      def to_sql(context)
        "lower(#{attribute.to_sql(context)}) = #{literal.to_sql(context).downcase}"
      end

      private

      def literal_allowed?(literal)
        literal.is_a?(Literals::String)
      end
    end
  end
end

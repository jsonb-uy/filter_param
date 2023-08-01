module FilterParam
  module AST
    class Not < UnaryExpression
      def to_sql(context)
        "NOT #{exp.to_inverse_sql(context)}"
      end
    end
  end
end

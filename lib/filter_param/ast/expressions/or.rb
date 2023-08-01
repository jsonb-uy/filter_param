module FilterParam
  module AST
    class Or < BinaryExpression
      def to_sql(context)
        "#{left.to_sql(context)} OR #{right.to_sql(context)}"
      end
    end
  end
end

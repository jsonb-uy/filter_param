module FilterParam
  module AST
    class And < BinaryExpression
      def to_sql(context)
        "#{left.to_sql(context)} AND #{right.to_sql(context)}"
      end
    end
  end
end

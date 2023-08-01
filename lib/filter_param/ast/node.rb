module FilterParam
  module AST
    class Node
      def accept(visitor)
        visitor.send(visit_method, self)
      end

      def to_sql(context)
        nil
      end

      def to_inverse_sql(context)
        to_sql(context)
      end

      private

      def visit_method
        "visit_#{self.class.name.demodulize.underscore}".to_sym
      end
    end
  end
end

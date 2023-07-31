module FilterParam
  module AST
    class Node
      def accept(visitor)
        visitor.send(visit_method, self)
      end

      private

      def visit_method
        "visit_#{self.class.name.demodulize.underscore}".to_sym
      end
    end
  end
end

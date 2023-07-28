module FilterParam
  module AST
    class Node
      def accept(visitor)
        visit_method = "visit_#{self.class.name.demodulize.underscore}"

        visitor.send(visit_method.to_sym, self)
      end
    end
  end
end

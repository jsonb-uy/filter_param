module FilterParam
  module Filter
    module AST
      module Nodes
        class Node
          def accept(visitor)
            visit_method = "visit_#{self.class.name.demodulize.underscore}"

            visitor.send(visit_method.to_sym, self)
          end
        end
      end
    end
  end
end

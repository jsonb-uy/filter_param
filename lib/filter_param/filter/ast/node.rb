module FilterParam
  module Filter
    module AST
      class Node
        attr_reader :children

        def initialize
          @children = nil
        end

        def accept(visitor)
          visit_method = "visit_#{self.class.name.demodulize.underscore}"

          visitor.send(visit_method.to_sym, self)
        end
      end
    end
  end
end

module FilterParam
  module Filter
    module AST
      class Node
        def accept(visitor)
          visit_method = "visit_#{self.class.name.demodulize.underscore}"

          visitor.send(visit_method.to_sym, self)
        end
      end

      class UnaryExpression < Node
        attr_reader :exp, :op

        def initialize(exp, operator)
          @exp = exp
          @op = operator
        end
      end

      class BinaryExpression < Node
        attr_reader :left, :op, :right

        def initialize(left, operator, right)
          @left = left
          @op = operator
          @right = right
        end
      end

      class Group < Node
        attr_reader :exp

        def initialize(exp)
          @exp = exp
        end
      end

      class Identifier < Node
        attr_reader :name

        def initialize(name)
          @name = name.to_s
        end

        def to_s
          name
        end
      end
    end
  end
end

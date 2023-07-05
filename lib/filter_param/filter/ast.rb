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
          super()

          @exp = exp
          @op = operator.to_s
        end
      end

      class BinaryExpression < Node
        attr_reader :left, :op, :right

        def initialize(left, operator, right)
          super()

          @left = left
          @op = operator.to_s
          @right = right
        end
      end

      class Group < Node
        attr_reader :exp

        def initialize(exp)
          super()

          @exp = exp
        end
      end

      class Identifier < Node
        attr_reader :name

        def initialize(name)
          super()

          @name = name.to_s
        end

        alias to_s name
      end

      class Literal < Node
        attr_reader :value

        def initialize(value = nil)
          super()

          @value = value
        end
      end
    end
  end
end

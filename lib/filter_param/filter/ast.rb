module FilterParam
  module Filter
    module AST
      class Node
        def accept(visitor)
          visitor.send(visit_method.to_sym, self)
        end

        private

        def visit_method
          klass_name = self.class.name

          klass_name = if i = klass_name.rindex("::")
                         klass_name[(i + 2)..-1]
                       else
                         klass_name
                       end

          "visit_#{underscore klass_name}"
        end

        def underscore(camel_cased_word)
          return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
          word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
          word.tr!("-".freeze, "_".freeze)
          word.downcase!
          word
        end
      end

      class UnaryExpression < Node
        attr_reader :exp, :op

        def initialize(exp, op)
          @exp = exp
          @op = op
        end
      end

      class BinaryExpression < Node
        attr_reader :left, :op, :right

        def initialize(left, op, right)
          @left = left
          @op = op
          @right = right
        end
      end

      class GroupExpression < Node
        attr_reader :exp

        def initialize(exp)
          @exp = exp
        end
      end

      class Identifier < Node
        attr_reader :name

        def initialize(name)
          @name = name
        end
      end
    end
  end
end

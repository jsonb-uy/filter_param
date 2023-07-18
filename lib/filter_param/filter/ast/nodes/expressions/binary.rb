module FilterParam
  module Filter
    module AST
      module Nodes
        module Expressions
          class Binary < Node
            def self.for(operator)
              case operator
              when :eq
                Equal
              when :neq
                NotEqual
              when :gt
                GreaterThan
              when :ge
                GreaterThanEqual
              when :lt
                LessThan
              when :le
                LessThanEqual
              when :sw
                StartsWith
              when :ew
                EndsWith
              when :co
                Contains
              end
            end

            attr_reader :left, :op, :right

            def initialize(left, operator, right)
              super()

              @left = left
              @op = operator.to_sym
              @right = right
            end

            private

            def raise_invalid_value!
              raise FilterParam::InvalidFilterValue.new("Filter value for `#{left.name}` cannot be a #{right.type}.")
            end
          end
        end
      end
    end
  end
end

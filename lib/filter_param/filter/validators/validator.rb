module FilterParam
  module Filter
    module Validators
      class Validator < Filter::Visitor
        def validate!(node)
          evaluate(node)
        end
      end
    end
  end
end

require "singleton"

module FilterParam
  module AST
    module Literals
      class Null < Literal
        include Singleton

        def data_type
          :null
        end

        def type_cast(type)
          self
        end
      end
    end
  end
end

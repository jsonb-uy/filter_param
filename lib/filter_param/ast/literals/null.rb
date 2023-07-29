require "singleton"

module FilterParam
  module AST
    module Literals
      class Null < Literal
        include Singleton
      end
    end
  end
end

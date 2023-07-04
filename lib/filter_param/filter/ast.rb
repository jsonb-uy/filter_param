module FilterParam
  module Filter
    module AST
      class UnaryExpression < Struct.new(:exp, :op); end
      class BinaryExpression < Struct.new(:left, :op, :right); end
      class GroupingExpression < Struct.new(:exp); end
      class Identifier < Struct.new(:name); end
    end
  end
end

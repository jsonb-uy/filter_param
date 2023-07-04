module FilterParam
  module AST
    class UnaryExpression < Struct.new(:exp, :op); end
    class BinaryExpression < Struct.new(:left, :op, :right); end
    class GroupingExpression < Struct.new(:exp); end
    class Field < Struct.new(:name); end
  end
end

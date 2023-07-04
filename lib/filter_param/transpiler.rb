module FilterParam
  class Transpiler
    def initialize(definition)
      @definition = definition
    end

    def transpile(expression)
      ASTTransformer.new.apply(Parser.new.parse(expression))
    end

    private

    attr_reader :definition
  end
end

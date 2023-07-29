module FilterParam
  module AST
    class Literal < Node
      attr_reader :value

      def initialize(value = nil)
        @value = value
      end

      def type_cast(type)
        return self if type.blank?

        send("to_#{type}")
      end
    end
  end
end

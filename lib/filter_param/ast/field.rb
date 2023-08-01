module FilterParam
  module AST
    class Field < Node
      attr_reader :name

      def initialize(name)
        super()

        @name = name.to_s
      end

      alias to_s name

      def to_sql(context)
        field_definition = context.fields[name]
        return name if field_definition.nil?

        field_definition[:rename].presence || name
      end
    end
  end
end

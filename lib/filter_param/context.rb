module FilterParam
  class Context
    def initialize(definition)
      @definition = definition
    end

    def fields
      definition.fields_hash
    end

    def field_type(field_name)
      definition.field_type(field_name)
    end

    private

    attr_reader :definition
  end
end

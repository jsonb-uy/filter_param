module FilterParam
  class Field
    TYPES = %i[boolean string integer decimal date datetime].freeze

    attr_reader :type, :name, :rename

    def initialize(name, type, options = {})
      @name = name
      @type = field_type(type)
      @rename = field_rename(options[:rename])
      @value_transformer = options[:value]
    end

    def transform_value(value)
      return value if value_transformer.blank?

      value_transformer.call(value)
    end

    private

    attr_reader :value_transformer

    def field_rename(rename)
      return rename.call(name) if rename.is_a?(Proc)

      rename
    end

    def field_type(type)
      type = (type.presence || :string).to_sym
      return type if type.in?(TYPES)

      raise UnknownType.new("Unknown type '#{type}' for field '#{name}'. Allowed types: #{TYPES}.")
    end
  end
end

module FilterParam
  class Definition
    attr_reader :fields_hash

    FIELD_TYPES = %i[string numeric boolean date datetime].freeze

    # Creates a new FilterParam definition that whitelists the columns that are allowed to
    # filtered (i.e. used in SQL WHERE condition).
    def initialize
      @fields_hash = {}
    end

    # Allows whitelisting columns using a block
    #
    # @param [Proc] block Field definition block
    #
    # @return [self] Definition instance
    def define(&block)
      raise ArgumentError.new("Missing block") unless block_given?

      instance_eval(&block)

      self
    end

    # Whitelist a column
    #
    # @param [String, Symbol] name column name
    # @param [Hash] options column options:
    #   * type [Symbol] expected field type:
    #     :string (default), :numeric, :boolean, :date, :datetime
    #   * rename [String, Proc] rename field in the formatted output.
    #     This can be a Proc code block that receives the :name as argument and
    #     returns a transformed field name.
    #
    # @return [self] Definition instance
    def field(name, **options)
      name = name.to_s
      return if name.blank?

      fields_hash[name] = preprocess_field_options(name, options)
      validate_field_options!(name, fields_hash[name])

      self
    end

    # Whitelist multiple columns with the same column options.
    #
    # @param [Array<String, Symbol>] names list of column names
    # @param [Hash] options column configuration options
    #
    # @see #field
    #
    # @return [self] Definition instance
    #
    def fields(*names, **options)
      raise ArgumentError.new(":rename should be a Proc") if options[:rename] && !options[:rename].is_a?(Proc)

      names.each { |name| field(name, **options) }

      self
    end

    # Get column options
    #
    # @param [String] name column name
    #
    # @return [Hash, NilClass] Default options
    def field_options(name)
      return nil if @fields_hash[name].nil?

      @fields_hash[name].dup
    end

    # Filters an :ar_relation by the filter :expression
    #
    # @param [ActiveRecord::Relation] ar_relation Relation to filter
    # @param [String] expression Filter expression.
    #
    def filter!(ar_relation, expression)
      transpiler = Filter::Transpiler.new(self)

      # ar_relation.where(
      #   transpiler.transpile!(expression)
      # )

      transpiler.transpile!(expression)
    end

    def field_type(field_name)
      fields_hash.dig(field_name, :type)
    end

    def field_permitted?(field_name)
      fields_hash.key? field_name
    end

    private

    def preprocess_field_options(field, options)
      options[:type] ||= :string
      options[:type] = options[:type].to_sym
      rename = options[:rename]
      return options unless rename.is_a?(Proc)

      options[:rename] = options[:rename].call(field)
      options
    end

    def validate_field_options!(field, options)
      type = options[:type]
      return if FIELD_TYPES.include?(type)

      raise UnknownType.new("Unknown type '#{type}' for field '#{field}'. Allowed types: #{FIELD_TYPES}.")
    end
  end
end

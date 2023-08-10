module FilterParam
  class Definition
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
    #     :string (default), :int, :decimal :boolean, :date, :datetime
    #   * rename [String, Proc] rename field in the formatted output.
    #     This can be a Proc code block that receives the :name as argument and
    #     returns a transformed field name.
    #   * value [Proc] pre-process literal operand values. This receives the :value
    #     argument parsed from the expression string and returns a transformed field value.
    #
    # @return [self] Definition instance
    def field(name, **options)
      name = name.to_s
      return if name.blank?

      fields_hash[name] = Field.new(name, options[:type], options)

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

    # Filters an :ar_relation by the filter :expression
    #
    # @param [ActiveRecord::Relation] ar_relation Relation to filter
    # @param [String] expression Filter expression.
    #
    def filter!(ar_relation, expression)
      transpiler = Transpiler.new(self)

      ar_relation.where(
        transpiler.transpile!(expression)
      )
    end

    # Returns the declared Field instance
    #
    # @param [String, Symbol] field_name
    #
    # @return [Field]
    def find_field!(field_name)
      field = fields_hash[field_name.to_s].presence
      return field if field

      raise UnknownField.new("Unknown field: '#{field_name}'")
    end

    # Returns the declared Field names
    #
    # @return [String]
    def field_names
      fields_hash.keys
    end

    private

    attr_reader :fields_hash
  end
end

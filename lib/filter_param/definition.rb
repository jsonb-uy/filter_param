module FilterParam
  # FilterParam definition that whitelists the columns that are allowed to
  # filtered (i.e. used in SQL WHERE condition) and the allowed scopes.
  class Definition
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
      restrict_string_rename!(options[:rename])

      names.each { |name| field(name, **options) }

      self
    end

    # Whitelist a scope name
    #
    # @param [String, Symbol] name scope name. ar_relation passed to `#filter!` must expose this scope.
    # @param [Hash] options column options:
    #   * rename [String, Proc] rename to actual scope name.
    #     This can be a Proc code block that receives the :name as argument and
    #     returns a transformed scope name.
    def scope(name, **options)
      name = name.to_s
      return if name.blank?

      scopes_hash[name] = Scope.new(name, options)

      self
    end

    # Whitelist multiple scope names with the same scope options.
    #
    # @param [Array<String, Symbol>] names list of scope names
    # @param [Hash] options scope configuration options
    #
    # @see #scope
    #
    # @return [self] Definition instance
    #
    def scopes(*names, **options)
      restrict_string_rename!(options[:rename])

      names.each { |name| scope(name, **options) }

      self
    end

    # Filters an :ar_relation by the filter :expression
    #
    # @param [ActiveRecord::Relation] ar_relation Relation to filter
    # @param [String] expression Filter expression.
    #
    def filter!(ar_relation, expression)
      transpiler = Transpiler.new(ar_relation, self)

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

    # Returns the declared Scope instance
    #
    # @param [String, Symbol] scope_name
    #
    # @return [Field]
    def find_scope!(scope_name)
      scope = scopes_hash[scope_name.to_s].presence
      return scope if scope

      raise UnknownScope.new("Unknown scope: '#{scope_name}'")
    end

    # Returns the declared Field names
    #
    # @return [Array<String>]
    def field_names
      fields_hash.keys
    end

    # Returns the declared Scope names
    #
    # @return [Array<String>]
    def scope_names
      scopes_hash.keys
    end

    private

    def fields_hash
      @fields_hash ||= {}
    end

    def scopes_hash
      @scopes_hash ||= {}
    end

    def restrict_string_rename!(rename)
      return if rename.blank? || rename.is_a?(Proc)

      raise ArgumentError.new(":rename should be a Proc")
    end
  end
end

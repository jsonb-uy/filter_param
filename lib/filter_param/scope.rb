module FilterParam
  class Scope
    attr_reader :name

    def initialize(name, options = {})
      @name = name
      @rename = scope_rename(options[:rename])
    end

    def actual_name
      rename.presence || name
    end

    private

    attr_reader :rename

    def scope_rename(rename)
      return rename.call(name) if rename.is_a?(Proc)

      rename
    end
  end
end

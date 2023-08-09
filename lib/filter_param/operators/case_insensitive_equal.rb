module FilterParam
  module Operators
    class CaseInsensitiveEqual < Operator
      def self.tag
        :eq_ci
      end

      def self.sql(attribute_name, value)
        "lower(#{field}) = #{quote(value.downcase)}"
      end
    end

    Operator.register(CaseInsensitiveEqual)
  end
end

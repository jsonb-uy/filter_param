module FilterParam
  module Operators
    class NotEqual < Operator
      def self.tag
        :neq
      end

      def self.sql(attribute_name, value)
        return "#{attribute_name} IS NOT NULL" if value.nil?

        "#{attribute_name} != #{quote(value)}"
      end

      def self.negated_sql(attribute_name, value)
        Operators::Equal.sql(attribute_name, value)
      end
    end

    Operator.register(NotEqual)
  end
end

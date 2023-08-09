module FilterParam
  module Operators
    class Equal < Operator
      def self.tag
        :eq
      end

      def self.sql(attribute_name, value)
        return "#{attribute_name} IS NULL" if value.nil?

        "#{attribute_name} = #{quote(value)}"
      end

      def self.negated_sql(attribute_name, value)
        Operators::NotEqual.sql(attribute_name, value)
      end
    end

    Operator.register(Equal)
  end
end

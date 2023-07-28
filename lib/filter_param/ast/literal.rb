require "bigdecimal"
require "date"
module FilterParam
  module AST
    class Literal < Node
      TYPES = %i[null string integer decimal boolean date datetime].freeze

      attr_reader :type, :value

      def initialize(type, value = nil)
        @type = type || :string
        self.value = value
      end

      def typecast!(type)
        return self if type.nil? || type == :null
        return self if type == self.type
        return self unless type.in?(TYPES)

        @type = type
        self.value = value

        self
      end

      def value=(value)
        @value = value.nil? ? nil : type_value(type, value)
      end

      def type_category
        case type
        when :date, :datetime
          :temporal
        when :integer, :decimal
          :numeric
        else
          type
        end
      end

      private

      def type_value(type, value)
        type_value_method = "value_to_#{type}".to_sym

        send(type_value_method, value)
      end

      def value_to_string(value)
        value.to_s
      end

      def value_to_boolean(value)
        value.to_s == "true"
      end

      def value_to_integer(value)
        Integer(value)
      rescue ArgumentError
        raise FilterParam::InvalidFilterValue.new("Invalid Integer: #{value}")
      end

      def value_to_decimal(value)
        BigDecimal(value)
      rescue ArgumentError
        raise FilterParam::InvalidFilterValue.new("Invalid Decimal: #{value}")
      end

      def value_to_date(value)
        Date.iso8601(value)
      rescue Date::Error
        raise FilterParam::InvalidFilterValue.new("Invalid ISO8601 Date: #{value}")
      end

      def value_to_datetime(value)
        DateTime.iso8601(value)
      rescue Date::Error
        raise FilterParam::InvalidFilterValue.new("Invalid ISO8601 Datetime: #{value}")
      end
    end
  end
end

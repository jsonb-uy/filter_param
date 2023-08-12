require "date"

module FilterParam
  module AST
    module Literals
      class DateTime < Date
        def initialize(value)
          @raw_value = value
          @value = ::DateTime.iso8601(value.to_s)
        rescue ::Date::Error
          raise FilterParam::InvalidLiteral.new("Invalid ISO8601 Datetime: #{value}")
        end

        def data_type
          :datetime
        end

        private

        attr_reader :raw_value

        def to_string
          Literals::String.new(raw_value)
        end

        def to_date
          Literals::Date.new(value)
        end

        def to_datetime
          self
        end
      end
    end
  end
end

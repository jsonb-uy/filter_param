require "date"

module FilterParam
  module AST
    module Literals
      class Date < Literal
        def initialize(value)
          @value = ::Date.iso8601(value.to_s)
        rescue ::Date::Error
          raise FilterParam::InvalidLiteral.new("Invalid ISO8601 Date: #{value}")
        end

        private

        def to_string
          Literals::String.new(value)
        end

        def to_date
          self
        end

        def to_datetime
          Literals::DateTime.new(value)
        end
      end
    end
  end
end

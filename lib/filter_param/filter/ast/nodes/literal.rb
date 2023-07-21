require "bigdecimal"
require "date"
module FilterParam
  module Filter
    module AST
      module Nodes
        class Literal < Node
          TYPES = %i[null string int decimal boolean date datetime].freeze

          attr_reader :type, :value

          def initialize(type, value = nil)
            @type = type
            @value = value.to_s unless type == :null

            coerce_value!
          end

          def type_category
            case type
            when :date, :datetime
              :temporal
            when :int, :decimal
              :numeric
            else
              type
            end
          end

          private

          def coerce_method
            @coerce_method ||= "coerce_to_#{type}!".to_sym
          end

          def coerce_value!
            return unless respond_to?(coerce_method, true)

            send(coerce_method)
          end

          def coerce_to_boolean!
            @value = value == "true"
          end

          def coerce_to_int!
            @value = Integer(value)
          end

          def coerce_to_decimal!
            @value = BigDecimal(value)
          end

          def coerce_to_date!
            @value = Date.iso8601(value)
          rescue Date::Error
            raise FilterParam::InvalidFilterValue.new("Invalid Date: #{value}")
          end

          def coerce_to_datetime!
            @value = DateTime.iso8601(value)
          rescue Date::Error
            raise FilterParam::InvalidFilterValue.new("Invalid Datetime: #{value}")
          end
        end
      end
    end
  end
end

module FilterParam
  module Operators
    class FieldValueFilterOperator < FieldFilterOperator
      class << self
        def sql(field, value)
          super(field)
        end

        private

        def sql_quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

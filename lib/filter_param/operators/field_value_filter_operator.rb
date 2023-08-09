module FilterParam
  module Operators
    class FieldValueFilterOperator < FieldFilterOperator
      class << self
        def sql(field, value)
          super(field)
        end
      end
    end
  end
end

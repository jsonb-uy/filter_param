module FilterParam
  module Filter
    module Validators
      class FieldPermissionValidator < Validator
        def visit_field(field)
          return field if definition.field_permitted?(field.name)

          raise UnpermittedField.new("Unpermitted filter field: '#{field.name}'")
        end
      end
    end
  end
end

module FilterParam
  module Filter
    class PermissionChecker < AST::Visitor
      def visit_field(field)
        return field if definition.field_permitted?(field.name)

        raise UnpermittedField.new("Unpermitted filter field: '#{field.name}'")
      end
    end
  end
end

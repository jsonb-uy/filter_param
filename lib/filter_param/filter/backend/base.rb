module FilterParam
  module Filter
    module Backend
      class Base < Filter::AST::Visitor
        def visit_group(group)
          "(#{visit_node(group.exp)})"
        end

        def visit_field(field)
          field_options = definition.field_options(field.name)
          return field if field_options.nil?

          field_options[:rename].presence || field.name
        end

        def visit_literal(literal)
          quote literal.value
        end

        def visit_null(null)
          nil
        end

        private

        def quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

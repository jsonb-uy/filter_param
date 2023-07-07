module FilterParam
  module Filter
    module Backends
      class Backend < Filter::AST::Visitor
        OPS_MAP = {
          and: "AND",
          or: "OR",
          not: "NOT",
          eq: "=",
          neq: "!=",
          le: "<=",
          lt: "<",
          ge: ">=",
          gt: ">",
          pr: "IS NOT NULL"
        }.freeze

        def visit_group(group)
          "(#{evaluate(group.exp)})"
        end

        def visit_field(field)
          field_options = definition.field_options(field.name)
          return field if field_options.nil?

          field_options[:rename].presence || field.name
        end

        def visit_literal(literal)
          literal.value
        end

        private

        def quote(value)
          ActiveRecord::Base.connection.quote(value)
        end
      end
    end
  end
end

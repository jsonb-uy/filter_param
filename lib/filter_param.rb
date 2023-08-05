# frozen_string_literal: true

require "parslet"
require "active_record"
require "active_support"
require "active_support/core_ext/object/inclusion"
require_relative "filter_param/ast/node"
require_relative "filter_param/ast/field"
require_relative "filter_param/ast/group"
require_relative "filter_param/ast/expressions"
require_relative "filter_param/ast/operators"
require_relative "filter_param/ast/literal"
require_relative "filter_param/ast/literals/null"
require_relative "filter_param/ast/literals/string"
require_relative "filter_param/ast/literals/boolean"
require_relative "filter_param/ast/literals/integer"
require_relative "filter_param/ast/literals/decimal"
require_relative "filter_param/ast/literals/date"
require_relative "filter_param/ast/literals/date_time"
require_relative "filter_param/visitor"
require_relative "filter_param/field_node_validator"
require_relative "filter_param/transformer"
require_relative "filter_param/parser"
require_relative "filter_param/transpiler"
require_relative "filter_param/definition"
require_relative "filter_param/version"

module FilterParam
  class BaseError < StandardError; end
  class UnknownType < BaseError; end
  class ExpressionError < BaseError; end
  class UnpermittedField < ExpressionError; end
  class InvalidLiteral < ExpressionError; end
  class ParseError < ExpressionError; end

  # Creates a new FilterParam definition that whitelists the columns that are allowed to
  # be filtered (i.e. used in SQL WHERE).
  #
  # @param [Proc] block Field definition block
  #
  # @example
  #  FilterParam.define do
  #    fields :first_name, :last_name
  #    field :birth_date, rename: bdate
  #  end
  #
  # @return [Definition] Filter param definition
  #
  def self.define(&block)
    Definition.new.define(&block)
  end
end

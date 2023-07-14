# frozen_string_literal: true

require "parslet"
require "active_record"
require "active_support"
require_relative "filter_param/filter/ast/nodes/node"
require_relative "filter_param/filter/ast/nodes/literal"
require_relative "filter_param/filter/ast/nodes/null"
require_relative "filter_param/filter/ast/nodes/field"
require_relative "filter_param/filter/ast/nodes/group"
require_relative "filter_param/filter/ast/nodes/binary_expression"
require_relative "filter_param/filter/ast/nodes/unary_expression"
require_relative "filter_param/filter/ast/visitor"
require_relative "filter_param/filter/ast/field_permission_checker"
require_relative "filter_param/filter/ast/field_null_value_checker"
require_relative "filter_param/filter/ast/transformer"
require_relative "filter_param/filter/parser"
require_relative "filter_param/filter/transpiler"
require_relative "filter_param/definition"
require_relative "filter_param/version"

module FilterParam
  class BaseError < StandardError; end
  class UnknownType < BaseError; end
  class ExpressionError < BaseError; end
  class UnpermittedField < ExpressionError; end
  class InvalidFilterValue < ExpressionError; end
  class TypeMismatch < ExpressionError; end
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

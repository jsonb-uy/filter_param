# frozen_string_literal: true

require "parslet"
require "active_record"
require "active_support"
require "active_support/core_ext/object/inclusion"
require_relative "filter_param/ast/node"
require_relative "filter_param/ast/literal"
require_relative "filter_param/ast/field"
require_relative "filter_param/ast/group"
require_relative "filter_param/ast/logical_expression"
require_relative "filter_param/ast/unary_expression"
require_relative "filter_param/ast/comparison"
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

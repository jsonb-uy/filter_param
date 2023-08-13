# frozen_string_literal: true

require "parslet"
require "active_record"
require "active_support"
require "active_support/core_ext/object/inclusion"
require_relative "filter_param/ast/node"
require_relative "filter_param/ast/attribute"
require_relative "filter_param/ast/expressions"
require_relative "filter_param/ast/group"
require_relative "filter_param/ast/scope"
require_relative "filter_param/ast/literal"
require_relative "filter_param/ast/literals/null"
require_relative "filter_param/ast/literals/string"
require_relative "filter_param/ast/literals/boolean"
require_relative "filter_param/ast/literals/integer"
require_relative "filter_param/ast/literals/decimal"
require_relative "filter_param/ast/literals/date"
require_relative "filter_param/ast/literals/date_time"
require_relative "filter_param/operator"
require_relative "filter_param/operators/group"
require_relative "filter_param/operators/field_filter_operator"
require_relative "filter_param/operators/and"
require_relative "filter_param/operators/or"
require_relative "filter_param/operators/not"
require_relative "filter_param/operators/equal"
require_relative "filter_param/operators/not_equal"
require_relative "filter_param/operators/case_insensitive_equal"
require_relative "filter_param/operators/less_than"
require_relative "filter_param/operators/less_than_equal"
require_relative "filter_param/operators/greater_than"
require_relative "filter_param/operators/greater_than_equal"
require_relative "filter_param/operators/starts_with"
require_relative "filter_param/operators/ends_with"
require_relative "filter_param/operators/contains"
require_relative "filter_param/operators/present"
require_relative "filter_param/transformer"
require_relative "filter_param/parser"
require_relative "filter_param/transpiler"
require_relative "filter_param/field"
require_relative "filter_param/scope"
require_relative "filter_param/definition"
require_relative "filter_param/version"

module FilterParam
  class BaseError < StandardError; end
  class UnknownType < BaseError; end
  class ExpressionError < BaseError; end
  class UnknownField < BaseError; end
  class UnknownScope < BaseError; end
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

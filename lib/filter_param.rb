# frozen_string_literal: true

require "parslet"
require "active_record"
require "active_support"
require_relative "filter_param/filter/ast"
require_relative "filter_param/filter/ast_transformer"
require_relative "filter_param/filter/parser"
require_relative "filter_param/filter/transpiler"
require_relative "filter_param/definition"
require_relative "filter_param/version"

module FilterParam
  class UnsupportedFilterField < StandardError; end

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

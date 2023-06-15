require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1) }
    rule(:space?) { space.maybe }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:digit) { match("[0-9]") }

    rule(:db_identifier) { match("[a-zA-Z_]") >> digit.maybe }
    rule(:table) { db_identifier.repeat(1) >> str(".") }
    rule(:field) { table.maybe >> db_identifier.repeat(1) >> space }

    rule(:integer) { digit.repeat(1).as(:int) }
    rule(:string_single_quoted) do
      single_quote >> (single_quote.absent? >> any).repeat.as(:str) >> single_quote
    end
    rule(:string_double_quoted) do
      double_quote >> (double_quote.absent? >> any).repeat.as(:str) >> double_quote
    end
    rule(:string) { string_single_quoted | string_double_quoted }
    rule(:value) { integer | string }

    rule(:eq) { str("eq").as(:eq) >> space }
    rule(:neq) { str("neq").as(:neq) >> space }
    rule(:operator) { eq | neq }
    rule(:filter_expression) { field.as(:field) >> operator >> value >> space? }

    rule(:expression) { value }
    root(:expression)
  end
end

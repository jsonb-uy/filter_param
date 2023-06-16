require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1) }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:escaped_char) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:any_digit) { match("[0-9]") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> any_digit.maybe }
    rule(:table_name) { identifier.repeat(1) >> dot }
    rule(:field_name) { (table_name.maybe >> identifier.repeat(1)).as(:field) }

    rule(:integer) do
      (
        (negative_sign >> non_zero_digit.repeat(1)) |
        (negative_sign.absent? >> any_digit.repeat(1))
      ).as(:int_value)
    end

    rule(:string_single_quoted) do
      single_quote >> (escaped_char | match("[^\']")).repeat.as(:string_value) >> single_quote
    end
    rule(:string_double_quoted) do
      double_quote >> (escaped_char | match("[^\"]")).repeat.as(:string_value) >> double_quote
    end
    rule(:string) { string_single_quoted | string_double_quoted }

    rule(:value) { integer | string }

    rule(:eq) { str("eq") }
    rule(:neq) { str("neq") }
    rule(:operator) { space >> (eq | neq).as(:op) >> space }
    rule(:filter_expression) { field_name >> operator >> value }

    rule(:expression) { filter_expression }
    root(:expression)
  end
end

require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1) }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(") }
    rule(:rparen) { str(")") }
    rule(:escaped_char) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:any_digit) { match("[0-9]") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> any_digit.maybe }
    rule(:table_name) { identifier.repeat(1) >> dot }
    rule(:field_name) { (table_name.maybe >> identifier.repeat(1)).as(:field) }
    rule(:and_op) { str("and") }
    rule(:or_op) { str("or") }
    rule(:logical_op) { (and_op | or_op).as(:logical_op) }

    # Literals
    rule(:null) { str("null").as(:null) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean) }
    rule(:integer) do
      (
        (negative_sign >> non_zero_digit.repeat(1)) |
        (negative_sign.absent? >> any_digit.repeat(1))
      ).as(:int)
    end
    rule(:string) do
      (single_quote >> (escaped_char | match("[^\']")).repeat.as(:string) >> single_quote) |
        (double_quote >> (escaped_char | match("[^\"]")).repeat.as(:string) >> double_quote)
    end
    rule(:literal) do
      null | boolean | integer | string
    end
    rule(:literal_paren) do
      lparen >> (literal | literal_paren) >> rparen
    end

    rule(:grouping) do
      lparen >> expression >> rparen
    end

    # Operations
    rule(:equality_op) { (str("eq") | str("neq")) }
    rule(:comparison_op) { (str("lt") | str("lte") | str("gt") | str("gte")) }
    rule(:filter_op) { (equality_op | comparison_op).as(:filter_op) }
    rule(:filter_exp) do
      (
        field_name >> space >> filter_op >>
          ((space.present? >> space >> (literal | literal_paren).as(:value)) | literal_paren.as(:value))
      ) |
      grouping
    end

    rule(:logical_exp) do
      filter_exp >> (space.present? >> space >> logical_op >> space >> logical_exp).repeat(0)
    end

    rule(:expression) { space? >> logical_exp >> space? }
    root(:expression)
  end
end

#where paid = (name = 'wa')
# (name eq false or name eq true) and (name neq false and name neq true)
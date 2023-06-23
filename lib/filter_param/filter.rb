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

    # Operations
    rule(:filter_op) do
      (str("eq") | str("neq") | str("lte") | str("lt") | str("gte") | str("gt")).as(:filter_op)
    end
    rule(:filter_exp) do
      grouping | (
        field_name >> space >> filter_op >>
          ((space.present? >> space >> (literal | literal_paren).as(:value)) | literal_paren.as(:value))
      ).as(:exp)
    end
    rule(:right_exp) do
      (space >> logical_exp) | (lparen.present? >> logical_exp)
    end

    rule(:grouping) do
      (lparen >> expression >> rparen).as(:group)
    end

    rule(:logical_exp) do
      (
        filter_exp.as(:left) >> space >> logical_op >> right_exp.as(:right)
      ).as(:exp) |
      filter_exp
    end

    rule(:expression) { space? >> logical_exp >> space? }
    root(:expression)
  end
end

require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1).ignore }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(") }
    rule(:rparen) { str(")") }
    rule(:escaped_char) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:any_digit) { match("[0-9]") }
    rule(:zero_digit) { str("0") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:sig_number) { non_zero_digit >> any_digit.repeat(1).maybe }
    rule(:zero_nonsig) { zero_digit.repeat(0).maybe.ignore }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> any_digit.maybe }
    rule(:table) { identifier.repeat(1) >> dot }
    rule(:field) { (table.maybe >> identifier.repeat(1)).as(:f) }

    # Literals
    rule(:null) { str("null").as(:null) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean) }
    rule(:integer) do
      (
        (negative_sign >> zero_nonsig >> sig_number) |
        (zero_nonsig >> sig_number) |
        (negative_sign.maybe.ignore >> zero_digit >> zero_nonsig)
      ).as(:int)
    end
    rule(:decimal) do
      (
        (negative_sign >> non_zero_digit.repeat(1) >> dot >> any_digit.repeat(1)) |
        (any_digit.repeat(1) >> dot >> any_digit.repeat(1))
      ).as(:decimal)
    end
    rule(:string) do
      (single_quote >> (escaped_char | match("[^\']")).repeat.as(:string) >> single_quote) |
        (double_quote >> (escaped_char | match("[^\"]")).repeat.as(:string) >> double_quote)
    end
    rule(:literal) do
      (null | boolean | decimal | integer | string).as(:val)
    end
    rule(:literal_paren) do
      lparen >> space? >> (literal | literal_paren) >> space? >> rparen
    end

    # Operations
    rule(:f_op) do
      (str("eq") | str("neq") | str("lte") | str("lt") | str("gte") | str("gt")).as(:f_op)
    end
    rule(:f_val) do
      literal_paren | (space >> (literal | literal_paren))
    end
    rule(:f_exp) do
      group | (field >> space >> f_op >> f_val).as(:exp)
    end

    rule(:l_op) { (str("and") | str("or")).as(:l_op) }
    rule(:l_exp) do
      (
        f_exp.as(:l_lexp) >> space >> l_op >> l_rexp.as(:l_rexp)
      ).as(:exp) |
      f_exp
    end
    rule(:l_rexp) { (space | lparen.present?) >> l_exp }
    rule(:empty_group) do
      (lparen >> space? >> empty_group >> space? >> rparen) | (lparen >> space? >> rparen)
    end
    rule(:group) { empty_group.ignore | (lparen >> expression >> rparen).as(:group) }
    rule(:expression) { space? >> l_exp >> space? }
    root(:expression)
  end
end

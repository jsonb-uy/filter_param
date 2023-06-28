require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1).ignore }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(") }
    rule(:rparen) { str(")") }
    rule(:escape_seq) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:digit) { match("[0-9]") }
    rule(:zero_digit) { str("0") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:sig_number) { non_zero_digit >> digit.repeat(1).maybe }
    rule(:zero_nonsig) { zero_digit.repeat(0).maybe.ignore }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> digit.maybe }
    rule(:table) { identifier.repeat(1) >> dot }
    rule(:field) { (table.maybe >> identifier.repeat(1)).as(:f) }
    rule(:date_year) { digit.repeat(4) }
    rule(:date_month) do
      (str("0") >> match("[1-9]")) | (str("1") >> match("[0-2]"))
    end
    rule(:date_monthday) do
      (str("0") >> match("[1-9]")) |
        (match("[1-2]") >> match("[0-9]")) |
        (str("3") >> match("[0-1]"))
    end
    rule(:date_sep) { str("-") }

    # Literals
    rule(:null) { str("null").as(:null) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean) }
    rule(:integer) do
      (
        (negative_sign.maybe >> zero_nonsig >> sig_number) |
        (negative_sign.maybe.ignore >> zero_digit >> zero_nonsig)
      ).as(:int)
    end
    rule(:decimal) do
      (
        (negative_sign.maybe >> zero_nonsig >> sig_number >> dot >> digit.repeat(1)) |
        (negative_sign.maybe >> zero_digit >> zero_nonsig >> dot >> digit.repeat(1))
      ).as(:decimal)
    end
    rule(:string) do
      (single_quote >> (escape_seq | match("[^\']")).repeat.as(:string) >> single_quote) |
        (double_quote >> (escape_seq | match("[^\"]")).repeat.as(:string) >> double_quote)
    end
    rule(:date) do
      (date_year >> date_sep >> date_month >> date_sep >> date_monthday).as(:date)
    end
    rule(:literal) do
      (null | boolean | date | decimal | integer | string).as(:val)
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

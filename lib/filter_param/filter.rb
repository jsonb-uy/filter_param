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
    rule(:hyphen) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> digit.maybe }
    rule(:table) { identifier.repeat(1) >> dot }
    rule(:field) { (table.maybe >> identifier.repeat(1)).as(:f) }

    # Literals
    rule(:null) { str("null").as(:null) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean) }

    rule(:integer) do
      (
        (hyphen.maybe >> zero_nonsig >> sig_number) |
        (hyphen.maybe.ignore >> zero_digit >> zero_nonsig)
      ).as(:int)
    end

    rule(:decimal) do
      (
        (hyphen.maybe >> zero_nonsig >> sig_number >> dot >> digit.repeat(1)) |
        (hyphen.maybe >> zero_digit >> zero_nonsig >> dot >> digit.repeat(1))
      ).as(:decimal)
    end

    rule(:string) do
      (single_quote >> (escape_seq | match("[^\']")).repeat.as(:string) >> single_quote) |
        (double_quote >> (escape_seq | match("[^\"]")).repeat.as(:string) >> double_quote)
    end

    rule(:date_yyyy) { digit.repeat(4) }
    rule(:date_mm) { (zero_digit >> non_zero_digit) | (str("1") >> match("[0-2]")) }
    rule(:date_md) { (zero_digit >> non_zero_digit) | (match("[1-2]") >> digit) | (str("3") >> match("[0-1]")) }
    rule(:date_iso8601) { date_yyyy >> hyphen >> date_mm >> hyphen >> date_md }
    rule(:date) do
      (single_quote >> date_iso8601.as(:date) >> single_quote) |
        (double_quote >> date_iso8601.as(:date) >> double_quote)
    end
    rule(:time_hh_mi) do
      (((zero_digit | str("1")) >> digit) | (str("2") >> match("[0-3]"))) >>
        str(":").maybe >> ((zero_digit >> digit) | (match("[1-5]") >> digit))
    end
    rule(:time_hh_mi_ss) do
      (
        time_hh_mi >> str(":") >> ((zero_digit >> digit) | (match("[1-5]") >> digit))
      )
    end
    rule(:time_hh_mi_ss_sss) { time_hh_mi_ss >> dot >> digit.repeat(3, 3) }
    rule(:time_tz) { str("Z") | (match("[\+\-]") >> time_hh_mi) }
    rule(:datetime_iso8601) do
      (date_iso8601 >> str("T") >> (time_hh_mi_ss_sss | time_hh_mi_ss) >> time_tz)
    end
    rule(:datetime) do
      (
        (single_quote >> datetime_iso8601.as(:datetime) >> single_quote) |
          (double_quote >> datetime_iso8601.as(:datetime) >> double_quote)
      )
    end

    rule(:literal) do
      (null | boolean | datetime | date | decimal | integer | string).as(:val)
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

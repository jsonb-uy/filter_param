require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1) }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(") >> space? }
    rule(:rparen) { space? >> str(")") }
    rule(:escaped_char) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:any_digit) { match("[0-9]") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> any_digit.maybe }
    rule(:table_name) { identifier.repeat(1) >> dot }
    rule(:field_name) { (table_name.maybe >> identifier.repeat(1)).as(:field) }
    rule(:op_and) { str("AND") | str("and") }
    rule(:op_or) { str("OR") | str("or") }
    rule(:logical_op) { op_and | op_or }

    # Literals
    rule(:null) do
      str("null").as(:null_literal)
    end

    rule(:integer) do
      (
        (negative_sign >> non_zero_digit.repeat(1)) |
        (negative_sign.absent? >> any_digit.repeat(1))
      ).as(:int_literal)
    end

    rule(:string_single_quoted) do
      single_quote >> (escaped_char | match("[^\']")).repeat.as(:string_literal) >> single_quote
    end
    rule(:string_double_quoted) do
      double_quote >> (escaped_char | match("[^\"]")).repeat.as(:string_literal) >> double_quote
    end
    rule(:string) { string_single_quoted | string_double_quoted }
    rule(:literal) { null | integer | string }
    rule(:literal_paren) { lparen >> (literal | literal_paren) >> rparen }

    # Operations
    rule(:eq) { str("eq") }
    rule(:neq) { str("neq") }
    rule(:filter_op) { (eq | neq).as(:filter_op) }

    rule(:expression) do
      field_name >> space >> filter_op >> (
        (space >> (literal_paren | literal)) | literal_paren
      )
    end
    rule(:expression_group) do
      space? >>
      (
        expression |
        (
          expression >> space >> logical_op >> space >> expression
        )
      ) >>
      space?
    end
    root(:expression_group)
  end
end

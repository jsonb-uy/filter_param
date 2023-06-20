require "parslet"

module FilterParam
  class Filter < Parslet::Parser
    rule(:space) { match("\s").repeat(1) }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(").as(:lparen) >> space? }
    rule(:rparen) { space? >> str(")").as(:rparen) }
    rule(:escaped_char) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:any_digit) { match("[0-9]") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:negative_sign) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> any_digit.maybe }
    rule(:table_name) { identifier.repeat(1) >> dot }
    rule(:field_name) { (table_name.maybe >> identifier.repeat(1)).as(:field) }
    rule(:op_and) { str("and").as(:logical_operator) }
    rule(:op_or) { str("or").as(:logical_operator) }
    rule(:logical_op) { space >> (op_and | op_or) >> space }

    # Literals
    rule(:null) { str("null").as(:null_literal) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean_literal) }
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
    rule(:literal) { null | boolean | integer | string }
    rule(:literal_paren) { lparen >> (literal | literal_paren) >> rparen }

    # Operations
    rule(:eq) { str("eq") }
    rule(:neq) { str("neq") }
    rule(:filter_op) { (eq | neq).as(:filter_op) }

    rule(:expression) do
      (
        field_name >> space >> filter_op >> (
          (space >> (literal_paren | literal)) | literal_paren
        )
      )
    end
    rule(:expression_group) do
      space? >>
        (lparen.present? >> lparen >> expression >> rparen) |
        (
          expression.as(:lexp) >>
          (
            (logical_op >> expression_group.as(:rexp)) |
            space?
          )
        )
    end
    root(:expression_group)
  end
end

# (name eq false or name eq true) and (name neq false and name neq true)
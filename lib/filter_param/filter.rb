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
    rule(:and_op) { str("and") }
    rule(:or_op) { str("or") }
    rule(:logical_op) { space >> (and_op | or_op).as(:logical_op) >> space }

    # Literals
    rule(:null) { str("null").as(:null_literal) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean_literal) }
    rule(:integer) do
      (
        (negative_sign >> non_zero_digit.repeat(1)) |
        (negative_sign.absent? >> any_digit.repeat(1))
      ).as(:int_literal)
    end
    rule(:string) do
      (single_quote >> (escaped_char | match("[^\']")).repeat.as(:string_literal) >> single_quote) |
        (double_quote >> (escaped_char | match("[^\"]")).repeat.as(:string_literal) >> double_quote)
    end
    rule(:literal) { null | boolean | integer | string }
    rule(:literal_paren) { lparen >> (literal | literal_paren) >> rparen }

    # Operations
    rule(:equality) { (str("eq") | str("neq")).as(:equality) }
    rule(:comparison) { (str("lt") | str("lte") | str("gt") | str("gte")).as(:comparison) }

    rule(:filter_op) { equality | comparison }
    rule(:filter) do
      (
        field_name >> space >> filter_op >> (
          (space >> (literal | literal_paren)) | literal_paren
        )
      ).as(:filter)
    end
    rule(:grouping) do
      lparen >> expression >> rparen
    end

    rule(:logical_exp) do
      logical_op.present? >>
        (expression.as(:left) >> logical_op.as(:logical_op) >> expression.as(:right))
    end

    rule(:expression) do
      logical_exp | filter | grouping
    end

    rule(:expressions) do
      space? >>
        (
          expression
        ) >>
      space?
    end

    root(:expressions)
  end
end

# (name eq false or name eq true) and (name neq false and name neq true)
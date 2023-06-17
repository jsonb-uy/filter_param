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
    rule(:value_parenthesized) { lparen >> (value | value_parenthesized) >> rparen }

    # Operations
    rule(:eq) { str("eq") }
    rule(:neq) { str("neq") }
    rule(:filter_op) { (eq | neq).as(:filter_op) }
    rule(:value_operation) do
      filter_op >>
        (
          (space >> value) | value_parenthesized
        )
    end

    rule(:expression) do
      field_name >> space >> value_operation
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

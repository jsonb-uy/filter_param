module FilterParam
  class Parser < Parslet::Parser
    rule(:space) { match("\s").repeat(1).ignore }
    rule(:space?) { space.maybe }
    rule(:dot) { str(".") }
    rule(:lparen) { str("(") }
    rule(:rparen) { str(")") }
    rule(:escape_seq) { str('\\').present? >> str('\\') >> any }
    rule(:double_quote) { str('"') }
    rule(:single_quote) { str("'") }
    rule(:digit) { match("[0-9]") }
    rule(:zero) { str("0") }
    rule(:non_zero_digit) { match("[1-9]") }
    rule(:sig_number) { non_zero_digit >> digit.repeat(1).maybe }
    rule(:zero_nonsig) { zero.repeat(0).maybe.ignore }
    rule(:hyphen) { str("-") }
    rule(:identifier) { match("[a-zA-Z_]") >> digit.maybe }
    rule(:table) { identifier.repeat(1) >> dot }
    rule(:attribute) { (table.maybe >> identifier.repeat(1)).as(:attribute) }
    rule(:scope_name) { identifier.repeat(1) }

    # Literals / types
    rule(:null) { str("null").as(:null) }
    rule(:boolean) { (str("true") | str("false")).as(:boolean) }

    rule(:integer) do
      (
        (hyphen.maybe >> zero_nonsig >> sig_number) |
        (hyphen.maybe.ignore >> zero >> zero_nonsig)
      ).as(:integer)
    end

    rule(:decimal) do
      (
        (hyphen.maybe >> zero_nonsig >> sig_number >> dot >> digit.repeat(1)) |
        (hyphen.maybe >> zero >> zero_nonsig >> dot >> digit.repeat(1))
      ).as(:decimal)
    end

    rule(:string) do
      (single_quote >> (escape_seq | match("[^\']")).repeat.as(:string) >> single_quote) |
        (double_quote >> (escape_seq | match("[^\"]")).repeat.as(:string) >> double_quote)
    end
    rule(:date_yyyy) { digit.repeat(4) }
    rule(:date_mm) { (zero >> non_zero_digit) | (str("1") >> match("[0-2]")) }
    rule(:date_md) { (zero >> non_zero_digit) | (match("[1-2]") >> digit) | (str("3") >> match("[0-1]")) }
    rule(:date_iso8601) { date_yyyy >> hyphen >> date_mm >> hyphen >> date_md }
    rule(:date) { quoted date_iso8601.as(:date) }
    rule(:time_hh_mi) do
      (((zero | str("1")) >> digit) | (str("2") >> match("[0-3]"))) >>
        str(":").maybe >> ((zero >> digit) | (match("[1-5]") >> digit))
    end
    rule(:time_hh_mi_ss) { time_hh_mi >> str(":") >> ((zero >> digit) | (match("[1-5]") >> digit)) }
    rule(:time_hh_mi_ss_sss) { time_hh_mi_ss >> dot >> digit.repeat(3, 6) }
    rule(:time_tz) { str("Z") | (match("[\+\-]") >> time_hh_mi) }
    rule(:datetime_iso8601) { date_iso8601 >> str("T") >> (time_hh_mi_ss_sss | time_hh_mi_ss) >> time_tz }
    rule(:datetime) { quoted datetime_iso8601.as(:datetime) }

    # Operations
    rule(:op_attr_binary) do
      binary_attr_operators.as(:operator)
    end
    rule(:op_attr_unary) { (unary_attr_operators).as(:operator) }
    rule(:op_logic_binary) { (str("and") | str("or")).as(:operator) }
    rule(:op_logic_unary) { str("not").as(:operator) }

    # Expressions
    rule(:literal) { (null | boolean | decimal | integer | datetime | date | string) }
    rule(:literal_paren) { lparen >> space? >> (literal | literal_paren) >> space? >> rparen }
    rule(:attr_value) { literal_paren | (space >> (literal | literal_paren)) }
    rule(:attr_exp) { (attribute >> space >> (op_attr_unary | (op_attr_binary >> attr_value.as(:val)))).as(:exp) }
    rule(:group) do
      empty_group.ignore |
        (lparen >> space? >> (binary_exp | unary_exp | attr_exp) >> space? >> rparen).as(:group) |
        (lparen >> space? >> group >> space? >> rparen)
    end
    rule(:empty_group) do
      (lparen >> space? >> empty_group >> space? >> rparen) | (lparen >> space? >> rparen)
    end
    rule(:empty_exp) { (space | str("")).ignore }
    rule(:scope_args) { literal >> space? >> (str(",") >> space? >> literal).repeat(0) }
    rule(:scope) { scope_name.as(:name) >> lparen >> space? >> scope_args.maybe.as(:args) >> space? >> rparen }
    rule(:primary) { group | attr_exp | scope.as(:scope) }

    rule(:unary_exp) do
      (op_logic_unary >> (space | lparen.present?) >> primary.as(:right)).as(:exp) | primary
    end
    rule(:binary_exp) do
      (
        unary_exp.as(:left) >> space >> op_logic_binary >> ((space | lparen.present?) >> exp).as(:right)
      ).as(:exp) | unary_exp
    end

    rule(:exp) { (space? >> binary_exp >> space?) }
    rule(:exp_root) { exp | empty_exp }
    root(:exp_root)

    def parse(expression, options = {})
      super(expression, options)
    rescue Parslet::ParseFailed => e
      parse_cause = e.parse_failure_cause.children.last

      raise_parse_error!(parse_cause)
    end

    private

    def quoted(atom_or_seq)
      (single_quote >> atom_or_seq >> single_quote) | (double_quote >> atom_or_seq >> double_quote)
    end

    def binary_attr_operators
      @@binary_attr_ops = operators_to_atoms(Operators::FieldFilterOperator.binaries.map(&:to_s))
    end

    def unary_attr_operators
      @@unary_attr_ops = operators_to_atoms(Operators::FieldFilterOperator.unaries.map(&:to_s))
    end

    def operators_to_atoms(operators)
      operators.sort_by(&:length)
               .reverse
               .map { |tag| str(tag) }
               .reduce(:|)
    end

    def raise_parse_error!(parse_cause)
      parse_cause = parse_cause.to_s
      invalid_expression = "Filter expression syntax error."

      if parse_cause.start_with?("Expected ")
        parse_cause = invalid_expression
      else
        unexpected_token = "Unexpected token"

        parse_cause.sub!("Don't know what to do with", unexpected_token)
        parse_cause.sub!(/(Failed to match).*.(at line 1)/, "#{unexpected_token} at")
        parse_cause.sub!(/(at line 1)/, "at")
      end

      raise ParseError.new(parse_cause)
    end
  end
end

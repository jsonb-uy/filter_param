require "parslet"

module FilterParam
  class Expression
    class ExpressionParser < Parslet::Parser
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
      rule(:field) { (table.maybe >> identifier.repeat(1)).as(:f) }

      # Literals / types
      rule(:null) { str("null").as(:null) }
      rule(:boolean) { (str("true") | str("false")).as(:boolean) }

      rule(:integer) do
        (
          (hyphen.maybe >> zero_nonsig >> sig_number) |
          (hyphen.maybe.ignore >> zero >> zero_nonsig)
        ).as(:int)
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
      rule(:time_hh_mi_ss_sss) { time_hh_mi_ss >> dot >> digit.repeat(3, 3) }
      rule(:time_tz) { str("Z") | (match("[\+\-]") >> time_hh_mi) }
      rule(:datetime_iso8601) { date_iso8601 >> str("T") >> (time_hh_mi_ss_sss | time_hh_mi_ss) >> time_tz }
      rule(:datetime) { quoted datetime_iso8601.as(:datetime) }

      # Operations
      rule(:op_filter_binary) do
        (str("eq_ci") | str("eq") | str("neq") | str("le") | str("lt") |
          str("sw") | str("ew") | str("co") | str("ge") | str("gt")).as(:op)
      end
      rule(:op_filter_unary) { str("pr").as(:op) }
      rule(:op_logic_binary) { (str("and") | str("or")).as(:op) }
      rule(:op_logic_unary) { str("not").as(:op) }

      # Expressions
      rule(:literal) { (null | boolean | decimal | integer | datetime | date | string).as(:val) }
      rule(:literal_paren) { lparen >> space? >> (literal | literal_paren) >> space? >> rparen }
      rule(:value) { literal_paren | (space >> (literal | literal_paren)) }
      rule(:field_exp) { (field >> space >> (op_filter_unary | (op_filter_binary >> value))).as(:exp) }
      rule(:group) do
        empty_group.ignore |
          (lparen >> (binary_exp | unary_exp | field_exp) >> rparen).as(:group) |
          (lparen >> group >> rparen)
      end
      rule(:empty_group) do
        (lparen >> space? >> empty_group >> space? >> rparen) | (lparen >> space? >> rparen)
      end
      rule(:primary) { group | field_exp }

      rule(:unary_exp) do
        (op_logic_unary >> (space | lparen.present?) >> primary.as(:right)).as(:exp) | primary
      end
      rule(:binary_exp) do
        (
          unary_exp.as(:left) >> space >> op_logic_binary >> ((space | lparen.present?) >> exp).as(:right)
        ).as(:exp) | unary_exp
      end

      rule(:exp) { space? >> binary_exp >> space? }
      rule(:exp_root) { exp.as(:root) }
      root(:exp_root)

      private

      def quoted(atom_or_seq)
        (single_quote >> atom_or_seq >> single_quote) | (double_quote >> atom_or_seq >> double_quote)
      end
    end

    private_constant :ExpressionParser

    attr_reader :expression_string

    def initialize(expression_string)
      @expression_string = expression_string
    end

    def tree
      @tree ||= ExpressionParser.new.parse(expression_string)
    end
  end
end

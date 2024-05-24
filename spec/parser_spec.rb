# frozen_string_literal: true

RSpec.describe FilterParam::Parser do
  def parse(expression)
    described_class.new.parse(expression)
  end

  def parse_value(expression)
    parse(expression)[:exp][:val].values.first.str
  end

  describe "#tree" do
    context "with invalid column name format" do
      it "raises an error" do
        invalid_column_names = [1, "a.1", "a a", ".a", "!", "a!", "'", "a.a.a"]

        invalid_column_names.each do |column|
          expect { parse("#{column} eq 1") }.to raise_error(FilterParam::ParseError)
        end
      end
    end

    context "with valid column name format" do
      it "correctly parses the column name" do
        column_names = ["a", "a.a", "_.a", "a_a.a", "a1", "a1.a", "a_1", "a.a_1", "_.__"]

        column_names.each do |column|
          expression = "#{column} eq 1"

          expect { parse(expression) }.not_to raise_error
          expect(parse(expression)[:exp][:attribute].str).to eql(column)
        end
      end
    end

    context "with an unrecognized filter operator" do
      it "raises an error" do
        expect { parse("name equals 1") }.to raise_error(FilterParam::ParseError)
        expect { parse("name = 1") }.to raise_error(FilterParam::ParseError)
        expect { parse("name + 1") }.to raise_error(FilterParam::ParseError)
      end
    end

    it "parses :eq 'equal' filter operator" do
      exp = parse("name eq 'john'")[:exp]
      expect(exp[:operator].str).to eql("eq")
      expect(exp[:attribute].str).to eql("name")
      expect(exp[:val][:string].str).to eql("john")
    end

    it "parses :eq_ci 'case-insensitive equal' filter operator" do
      exp = parse("name eq_ci 'JOhn'")[:exp]
      expect(exp[:operator].str).to eql("eq_ci")
      expect(exp[:attribute].str).to eql("name")
      expect(exp[:val][:string].str).to eql("JOhn")
    end

    it "parses :ne 'not equal' filter operator" do
      exp = parse("name ne 'John'")[:exp]
      expect(exp[:operator].str).to eql("ne")
      expect(exp[:attribute].str).to eql("name")
      expect(exp[:val][:string].str).to eql("John")
    end

    it "parses :co 'contains' filter operator" do
      exp = parse("users.name co 'oh'")[:exp]
      expect(exp[:operator].str).to eql("co")
      expect(exp[:attribute].str).to eql("users.name")
      expect(exp[:val][:string].str).to eql("oh")
    end

    it "parses :sw 'starts with' filter operator" do
      exp = parse("users.name sw 'Jo'")[:exp]
      expect(exp[:operator].str).to eql("sw")
      expect(exp[:attribute].str).to eql("users.name")
      expect(exp[:val][:string].str).to eql("Jo")
    end

    it "parses :ew 'ends with' filter operator" do
      exp = parse("users.name ew 'hn'")[:exp]
      expect(exp[:operator].str).to eql("ew")
      expect(exp[:attribute].str).to eql("users.name")
      expect(exp[:val][:string].str).to eql("hn")
    end

    it "parses :gt 'greater than' filter operator" do
      exp = parse("width gt 3")[:exp]
      expect(exp[:operator].str).to eql("gt")
      expect(exp[:attribute].str).to eql("width")
      expect(exp[:val][:integer].str).to eql("3")
    end

    it "parses :ge 'greater than or equal' filter operator" do
      exp = parse("width ge 300.10")[:exp]
      expect(exp[:operator].str).to eql("ge")
      expect(exp[:attribute].str).to eql("width")
      expect(exp[:val][:decimal].str).to eql("300.10")
    end

    it "parses :lt 'less than' filter operator" do
      exp = parse("weight lt 12059.239")[:exp]
      expect(exp[:operator].str).to eql("lt")
      expect(exp[:attribute].str).to eql("weight")
      expect(exp[:val][:decimal].str).to eql("12059.239")
    end

    it "parses :le 'less than or equal' filter operator" do
      exp = parse("weight le 999")[:exp]
      expect(exp[:operator].str).to eql("le")
      expect(exp[:attribute].str).to eql("weight")
      expect(exp[:val][:integer].str).to eql("999")
    end

    it "parses :pr 'present' filter operator" do
      exp = parse("surname pr")[:exp]
      expect(exp[:operator].str).to eql("pr")
      expect(exp[:attribute].str).to eql("surname")

      expect(parse("surname pr")[:exp][:operator].str).to eql("pr")
    end

    it "parses null filter value" do
      expect(parse("name eq null")[:exp][:val][:null].str).to eql("null")
    end

    it "parses boolean filter value" do
      expect(parse_value("name eq true")).to eql("true")
      expect(parse_value("name eq false")).to eql("false")
    end

    it "parses positive integer filter value" do
      expect(parse_value("age ge 1")).to eql("1")
      expect(parse_value("age ge 420")).to eql("420")
      expect(parse_value("age ge 100003")).to eql("100003")
      expect(parse_value("age ge 01")).to eql("1")
      expect(parse_value("age ge 00023")).to eql("23")
      expect(parse_value("age ge 000230")).to eql("230")
      expect(parse_value("age ge 02301")).to eql("2301")
    end

    it "parses zero integer filter value" do
      expect(parse_value("age ge 00000")).to eql("0")
      expect(parse_value("age ge 00")).to eql("0")
      expect(parse_value("age ge 0")).to eql("0")
      expect(parse_value("age ge -0")).to eql("0")
      expect(parse_value("age ge -000")).to eql("0")
    end

    it "parses negative integer filter value" do
      expect(parse_value("age ge -1")).to eql("-1")
      expect(parse_value("age ge -420")).to eql("-420")
      expect(parse_value("age ge -100003")).to eql("-100003")
      expect(parse_value("age ge -01")).to eql("-1")
      expect(parse_value("age ge -00023")).to eql("-23")
      expect(parse_value("age ge -000230")).to eql("-230")
      expect(parse_value("age ge -02301")).to eql("-2301")
    end

    it "parses positive decimal filter value" do
      expect(parse_value("age ge 1.0")).to eql("1.0")
      expect(parse_value("age ge 420.101")).to eql("420.101")
      expect(parse_value("age ge 58456.100003")).to eql("58456.100003")
      expect(parse_value("age ge 09.01")).to eql("9.01")
      expect(parse_value("age ge 00900.00023")).to eql("900.00023")
      expect(parse_value("age ge 73.02301")).to eql("73.02301")
      expect(parse_value("age ge 0.0958")).to eql("0.0958")
    end

    it "parses negative decimal filter value" do
      expect(parse_value("age ge -1.0")).to eql("-1.0")
      expect(parse_value("age ge -420.101")).to eql("-420.101")
      expect(parse_value("age ge -58456.100003")).to eql("-58456.100003")
      expect(parse_value("age ge -09.01")).to eql("-9.01")
      expect(parse_value("age ge -00900.00023")).to eql("-900.00023")
      expect(parse_value("age ge -73.02301")).to eql("-73.02301")
      expect(parse_value("age ge -0.0958")).to eql("-0.0958")
    end

    it "parses zero decimal filter value" do
      expect(parse_value("age ge 00.000")).to eql("0.000")
      expect(parse_value("age ge 0.00")).to eql("0.00")
      expect(parse_value("age ge 0.0")).to eql("0.0")
      expect(parse_value("age ge -0.0")).to eql("-0.0")
      expect(parse_value("age ge -0.00")).to eql("-0.00")
    end

    it "parses string filter value" do
      expect(parse_value("name eq 'john'")).to eql("john")
      expect(parse_value("name eq \"john\"")).to eql("john")
      expect(parse_value('name eq \'john\'')).to eql("john")
      expect(parse_value('name eq "john"')).to eql("john")
    end

    it "parses date filter value" do
      expect(parse_value("birthdate eq \"2023-04-23\"")).to eql("2023-04-23")
      expect(parse_value("birthdate eq '2023-04-23'")).to eql("2023-04-23")
      expect(parse_value("birthdate eq \"2023-01-01\"")).to eql("2023-01-01")
      expect(parse_value("birthdate eq '2023-12-31'")).to eql("2023-12-31")
    end

    it "parses datetime filter value" do
      expect(parse_value("expiry le \"2017-06-04T10:15:30Z\"")).to eql("2017-06-04T10:15:30Z")
      expect(parse_value("expiry ge \"2017-06-04T10:15:30.999Z\"")).to eql("2017-06-04T10:15:30.999Z")
      expect(parse_value("expiry le '2017-06-04T10:15:30Z'")).to eql("2017-06-04T10:15:30Z")
      expect(parse_value("expiry ge '2017-06-04T10:15:30.999Z'")).to eql("2017-06-04T10:15:30.999Z")
      expect(parse_value("expiry le \"2017-06-04T10:15:30+09:00\"")).to eql("2017-06-04T10:15:30+09:00")
      expect(parse_value("expiry ge \"2017-06-04T10:15:30.999-08:30\"")).to eql("2017-06-04T10:15:30.999-08:30")
      expect(parse_value("expiry le '2017-06-04T10:15:30+00:30'")).to eql("2017-06-04T10:15:30+00:30")
      expect(parse_value("expiry le '2017-06-04T10:15:30+00:00'")).to eql("2017-06-04T10:15:30+00:00")
      expect(parse_value("expiry ge '2017-06-04T10:15:30.999-07:00'")).to eql("2017-06-04T10:15:30.999-07:00")
      expect(parse_value("expiry le \"2017-06-04T10:15:30+0900\"")).to eql("2017-06-04T10:15:30+0900")
      expect(parse_value("expiry ge \"2017-06-04T10:15:30.999-0830\"")).to eql("2017-06-04T10:15:30.999-0830")
      expect(parse_value("expiry le '2017-06-04T10:15:30+0030'")).to eql("2017-06-04T10:15:30+0030")
      expect(parse_value("expiry le '2017-06-04T10:15:30+0000'")).to eql("2017-06-04T10:15:30+0000")
      expect(parse_value("expiry ge '2017-06-04T10:15:30.999-0700'")).to eql("2017-06-04T10:15:30.999-0700")
    end

    it "parses :or logical operator" do
      exp = parse("name eq 'john' or surname eq 'doe'")[:exp]
      left = exp[:left][:exp]
      right = exp[:right][:exp]

      expect(exp[:operator].str).to eql("or")
      expect(left[:attribute].str).to eql("name")
      expect(left[:operator].str).to eql("eq")
      expect(left[:val][:string].str).to eql("john")
      expect(right[:attribute].str).to eql("surname")
      expect(right[:operator].str).to eql("eq")
      expect(right[:val][:string].str).to eql("doe")
    end

    it "parses :and logical operator" do
      exp = parse("name eq 'jane' and surname ne 'doe'")[:exp]
      left = exp[:left][:exp]
      right = exp[:right][:exp]

      expect(exp[:operator].str).to eql("and")
      expect(left[:attribute].str).to eql("name")
      expect(left[:operator].str).to eql("eq")
      expect(left[:val][:string].str).to eql("jane")
      expect(right[:attribute].str).to eql("surname")
      expect(right[:operator].str).to eql("ne")
      expect(right[:val][:string].str).to eql("doe")
    end

    it "parses :not logical operator" do
      exp = parse("not name eq 'jane' and not(surname eq 'doe' and name eq 'john')")[:exp]
      left_neg_exp = exp[:left][:exp]
      right_neg_exp = exp[:right][:exp]

      expect(exp[:operator].str).to eql("and")

      expect(left_neg_exp[:operator].str).to eql("not")
      expect(left_neg_exp[:right][:exp][:attribute].str).to eql("name")
      expect(left_neg_exp[:right][:exp][:operator].str).to eql("eq")
      expect(left_neg_exp[:right][:exp][:val][:string].str).to eql("jane")

      expect(right_neg_exp[:operator].str).to eql("not")
      expect(right_neg_exp[:right][:group][:exp][:operator].str).to eql("and")
      expect(right_neg_exp[:right][:group][:exp][:left][:exp][:operator].str).to eql("eq")
      expect(right_neg_exp[:right][:group][:exp][:left][:exp][:attribute].str).to eql("surname")
      expect(right_neg_exp[:right][:group][:exp][:left][:exp][:val][:string].str).to eql("doe")
      expect(right_neg_exp[:right][:group][:exp][:right][:exp][:operator].str).to eql("eq")
      expect(right_neg_exp[:right][:group][:exp][:right][:exp][:attribute].str).to eql("name")
      expect(right_neg_exp[:right][:group][:exp][:right][:exp][:val][:string].str).to eql("john")
    end

    context "value parenthesization" do
      it "correctly parses different formats" do
        expect(parse("id eq(42)")[:exp][:val][:integer].str).to eql("42")
        expect(parse("id eq (42)")[:exp][:val][:integer].str).to eql("42")
        expect(parse("id eq ((42))")[:exp][:val][:integer].str).to eql("42")
        expect(parse("id eq ( (   ( 42)) )")[:exp][:val][:integer].str).to eql("42")
      end

      it "requires parentheses to be pairs" do
        expect { parse("id eq(42") }.to raise_error(FilterParam::ParseError)
        expect { parse("id eq ((42)") }.to raise_error(FilterParam::ParseError)
        expect { parse("id eq 42)") }.to raise_error(FilterParam::ParseError)
        expect { parse("id eq (42))") }.to raise_error(FilterParam::ParseError)
      end
    end

    context "expression parenthesization" do
      it "correctly parses different formats" do
        expect { parse("id eq 1") }.not_to raise_error
        expect { parse("(id eq 1)") }.not_to raise_error
        expect { parse("((id eq 1))") }.not_to raise_error
        expect { parse("(id eq (1))") }.not_to raise_error
        expect { parse("((id eq (1)))") }.not_to raise_error
        expect { parse("(id eq(1))") }.not_to raise_error
        expect { parse("((id eq(1)))") }.not_to raise_error

        expect { parse("id ne 1 and name ne 'John'") }.not_to raise_error
        expect { parse("(id ne 1) and (name ne 'John')") }.not_to raise_error
        expect { parse("((id ne 1)) and ((name ne 'John'))") }.not_to raise_error
        expect { parse("(id ne 1 and name ne 'John')") }.not_to raise_error
        expect { parse("((id ne 1 and name ne 'John'))") }.not_to raise_error
        expect { parse("(((id ne 1) and (name ne 'John')))") }.not_to raise_error
        expect { parse("id ne 1 and name ne 'John' and name ne 'Jane'") }.not_to raise_error
        expect { parse("id ne 1 and(name eq 'John' or name eq 'Jane')") }.not_to raise_error
      end

      it "ignores empty parentheses" do
        expect(parse(" () ")).to eql("")
        expect(parse(" (  ) ")).to eql("")
        expect(parse(" ( ( )) ")).to eql("")
        expect(parse("(())")).to eql("")
      end
    end

    it "ignores blank expression" do
      expect(parse(" ")).to be_nil
      expect(parse("")).to be_nil
      expect(parse("          ")).to be_nil
    end
  end
end

# frozen_string_literal: true

RSpec.describe FilterParam::Filter do
  def parse(expression)
    described_class.new.parse(expression)
  end

  describe "#parse" do
    context "with invalid column name format" do
      it "raises an error" do
        invalid_column_names = [1, "a.1", "a a", ".a", "!", "a!", "'", "a.a.a"]

        invalid_column_names.each do |column|
          expect { parse("#{column} eq 1") }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    context "with valid column name format" do
      it "correctly parses the column name" do
        column_names = ["a", "a.a", "_.a", "a_a.a", "a1", "a1.a", "a_1", "a.a_1", "_.__"]

        column_names.each do |column|
          expression = "#{column} eq 1"

          expect { parse(expression) }.not_to raise_error
          expect(parse(expression)[:exp][:f].str).to eql(column)
        end
      end
    end

    context "with an unrecognized filter operator" do
      it "raises an error" do
        expect { parse("name equals 1") }.to raise_error(Parslet::ParseFailed)
        expect { parse("name = 1") }.to raise_error(Parslet::ParseFailed)
        expect { parse("name + 1") }.to raise_error(Parslet::ParseFailed)
      end
    end

    it "parses :eq filter operator" do
      expect(parse("name eq 'john'")[:exp][:f_op].str).to eql("eq")
    end

    it "parses :neq filter operator" do
      expect(parse("name neq 'john'")[:exp][:f_op].str).to eql("neq")
    end

    it "parses null filter value" do
      expect(parse("name eq null")[:exp][:val][:null].str).to eql("null")
    end

    it "parses boolean filter value" do
      expect(parse("name eq true")[:exp][:val][:boolean].str).to eql("true")
      expect(parse("name eq false")[:exp][:val][:boolean].str).to eql("false")
    end

    it "parses positive integer filter value" do
      expect(parse("age gte 1")[:exp][:val][:int].str).to eql("1")
      expect(parse("age gte 420")[:exp][:val][:int].str).to eql("420")
      expect(parse("age gte 100003")[:exp][:val][:int].str).to eql("100003")
      expect(parse("age gte 01")[:exp][:val][:int].str).to eql("1")
      expect(parse("age gte 00023")[:exp][:val][:int].str).to eql("23")
      expect(parse("age gte 000230")[:exp][:val][:int].str).to eql("230")
      expect(parse("age gte 02301")[:exp][:val][:int].str).to eql("2301")
    end

    it "parses zero integer filter value" do
      expect(parse("age gte 00000")[:exp][:val][:int].str).to eql("0")
      expect(parse("age gte 00")[:exp][:val][:int].str).to eql("0")
      expect(parse("age gte 0")[:exp][:val][:int].str).to eql("0")
      expect(parse("age gte -0")[:exp][:val][:int].str).to eql("0")
      expect(parse("age gte -000")[:exp][:val][:int].str).to eql("0")
    end

    it "parses negative integer filter value" do
      expect(parse("age gte -1")[:exp][:val][:int].str).to eql("-1")
      expect(parse("age gte -420")[:exp][:val][:int].str).to eql("-420")
      expect(parse("age gte -100003")[:exp][:val][:int].str).to eql("-100003")
      expect(parse("age gte -01")[:exp][:val][:int].str).to eql("-1")
      expect(parse("age gte -00023")[:exp][:val][:int].str).to eql("-23")
      expect(parse("age gte -000230")[:exp][:val][:int].str).to eql("-230")
      expect(parse("age gte -02301")[:exp][:val][:int].str).to eql("-2301")
    end

    it "parses positive decimal filter value" do
      expect(parse("age gte 1.0")[:exp][:val][:decimal].str).to eql("1.0")
      expect(parse("age gte 420.101")[:exp][:val][:decimal].str).to eql("420.101")
      expect(parse("age gte 58456.100003")[:exp][:val][:decimal].str).to eql("58456.100003")
      expect(parse("age gte 09.01")[:exp][:val][:decimal].str).to eql("9.01")
      expect(parse("age gte 00900.00023")[:exp][:val][:decimal].str).to eql("900.00023")
      expect(parse("age gte 73.02301")[:exp][:val][:decimal].str).to eql("73.02301")
      expect(parse("age gte 0.0958")[:exp][:val][:decimal].str).to eql("0.0958")
    end

    it "parses negative decimal filter value" do
      expect(parse("age gte -1.0")[:exp][:val][:decimal].str).to eql("-1.0")
      expect(parse("age gte -420.101")[:exp][:val][:decimal].str).to eql("-420.101")
      expect(parse("age gte -58456.100003")[:exp][:val][:decimal].str).to eql("-58456.100003")
      expect(parse("age gte -09.01")[:exp][:val][:decimal].str).to eql("-9.01")
      expect(parse("age gte -00900.00023")[:exp][:val][:decimal].str).to eql("-900.00023")
      expect(parse("age gte -73.02301")[:exp][:val][:decimal].str).to eql("-73.02301")
      expect(parse("age gte -0.0958")[:exp][:val][:decimal].str).to eql("-0.0958")
    end

    it "parses zero decimal filter value" do
      expect(parse("age gte 00.000")[:exp][:val][:decimal].str).to eql("0.000")
      expect(parse("age gte 0.00")[:exp][:val][:decimal].str).to eql("0.00")
      expect(parse("age gte 0.0")[:exp][:val][:decimal].str).to eql("0.0")
      expect(parse("age gte -0.0")[:exp][:val][:decimal].str).to eql("-0.0")
      expect(parse("age gte -0.00")[:exp][:val][:decimal].str).to eql("-0.00")
    end

    it "parses string filter value" do
      expect(parse("name eq 'john'")[:exp][:val][:string].str).to eql("john")
      expect(parse("name eq \"john\"")[:exp][:val][:string].str).to eql("john")
      expect(parse('name eq \'john\'')[:exp][:val][:string].str).to eql("john")
      expect(parse('name eq "john"')[:exp][:val][:string].str).to eql("john")
    end

    it "parses date filter value" do
      expect(parse("birthdate eq \"2023-04-23\"")[:exp][:val][:date].str).to eql("2023-04-23")
      expect(parse("birthdate eq '2023-04-23'")[:exp][:val][:date].str).to eql("2023-04-23")
      expect(parse("birthdate eq \"2023-01-01\"")[:exp][:val][:date].str).to eql("2023-01-01")
      expect(parse("birthdate eq '2023-12-31'")[:exp][:val][:date].str).to eql("2023-12-31")
    end

    it "parses datetime filter value" do
      expect(parse("created_at lte \"2017-06-04T10:15:30Z\"")[:exp][:val][:datetime].str).to eql("2017-06-04T10:15:30Z")
      expect(parse("created_at gte \"2017-06-04T10:15:30.999Z\"")[:exp][:val][:datetime].str).to eql("2017-06-04T10:15:30.999Z")
      expect(parse("created_at lte '2017-06-04T10:15:30Z'")[:exp][:val][:datetime].str).to eql("2017-06-04T10:15:30Z")
      expect(parse("created_at gte '2017-06-04T10:15:30.999Z'")[:exp][:val][:datetime].str).to eql("2017-06-04T10:15:30.999Z")
    end

    it "parses :or logical operator" do
      exp = parse("name eq 'john' or surname eq 'doe'")[:exp]
      left = exp[:l_lexp][:exp]
      right = exp[:l_rexp][:exp]

      expect(exp[:l_op].str).to eql("or")
      expect(left[:f].str).to eql("name")
      expect(left[:f_op].str).to eql("eq")
      expect(left[:val][:string].str).to eql("john")
      expect(right[:f].str).to eql("surname")
      expect(right[:f_op].str).to eql("eq")
      expect(right[:val][:string].str).to eql("doe")
    end

    it "parses :and logical operator" do
      exp = parse("name eq 'jane' and surname neq 'doe'")[:exp]
      left = exp[:l_lexp][:exp]
      right = exp[:l_rexp][:exp]

      expect(exp[:l_op].str).to eql("and")
      expect(left[:f].str).to eql("name")
      expect(left[:f_op].str).to eql("eq")
      expect(left[:val][:string].str).to eql("jane")
      expect(right[:f].str).to eql("surname")
      expect(right[:f_op].str).to eql("neq")
      expect(right[:val][:string].str).to eql("doe")
    end

    context "value parenthesization" do
      it "correctly parses different formats" do
        expect(parse("id eq(42)")[:exp][:val][:int].str).to eql("42")
        expect(parse("id eq (42)")[:exp][:val][:int].str).to eql("42")
        expect(parse("id eq ((42))")[:exp][:val][:int].str).to eql("42")
        expect(parse("id eq ( (   ( 42)) )")[:exp][:val][:int].str).to eql("42")
      end

      it "requires parentheses to be pairs" do
        expect { parse("id eq(42") }.to raise_error(Parslet::ParseFailed)
        expect { parse("id eq ((42)") }.to raise_error(Parslet::ParseFailed)
        expect { parse("id eq 42)") }.to raise_error(Parslet::ParseFailed)
        expect { parse("id eq (42))") }.to raise_error(Parslet::ParseFailed)
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

        expect { parse("id neq 1 and name neq 'John'") }.not_to raise_error
        expect { parse("(id neq 1) and (name neq 'John')") }.not_to raise_error
        expect { parse("((id neq 1)) and ((name neq 'John'))") }.not_to raise_error
        expect { parse("(id neq 1 and name neq 'John')") }.not_to raise_error
        expect { parse("((id neq 1 and name neq 'John'))") }.not_to raise_error
        expect { parse("(((id neq 1) and (name neq 'John')))") }.not_to raise_error
        expect { parse("id neq 1 and name neq 'John' and name neq 'Jane'") }.not_to raise_error
        expect { parse("id neq 1 and(name eq 'John' or name eq 'Jane')") }.not_to raise_error
      end

      it "ignores empty parentheses" do
        expect(parse(" () ")).to eql("")
        expect(parse(" (  ) ")).to eql("")
        expect(parse(" ( ( )) ")).to eql("")
        expect(parse("(())")).to eql("")
      end
    end

    xit "ignores whitespace sequences" do
      expect(parse(" ")).to eql("")
      expect(parse("          ")).to eql("")
    end
  end
end

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
          expect(parse(expression)[:exp][:field].str).to eql(column)
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
      expect(parse("name eq 'john'")[:exp][:filter_op].str).to eql("eq")
    end

    it "parses :neq filter operator" do
      expect(parse("name neq 'john'")[:exp][:filter_op].str).to eql("neq")
    end

    it "parses null filter value" do
      expect(parse("name eq null")[:exp][:value][:null].str).to eql("null")
    end

    it "parses boolean filter value" do
      expect(parse("name eq true")[:exp][:value][:boolean].str).to eql("true")
      expect(parse("name eq false")[:exp][:value][:boolean].str).to eql("false")
    end

    it "parses string filter value" do
      expect(parse("name eq 'john'")[:exp][:value][:string].str).to eql("john")
      expect(parse("name eq \"john\"")[:exp][:value][:string].str).to eql("john")
      expect(parse('name eq \'john\'')[:exp][:value][:string].str).to eql("john")
      expect(parse('name eq "john"')[:exp][:value][:string].str).to eql("john")
    end

    it "parses :or logical operator" do
      exp = parse("name eq 'john' or surname eq 'doe'")[:exp]
      left = exp[:left][:exp]
      right = exp[:right][:exp]

      expect(exp[:logic_op].str).to eql("or")
      expect(left[:field].str).to eql("name")
      expect(left[:filter_op].str).to eql("eq")
      expect(left[:value][:string].str).to eql("john")
      expect(right[:field].str).to eql("surname")
      expect(right[:filter_op].str).to eql("eq")
      expect(right[:value][:string].str).to eql("doe")
    end

    it "parses :and logical operator" do
      exp = parse("name eq 'jane' and surname neq 'doe'")[:exp]
      left = exp[:left][:exp]
      right = exp[:right][:exp]

      expect(exp[:logic_op].str).to eql("and")
      expect(left[:field].str).to eql("name")
      expect(left[:filter_op].str).to eql("eq")
      expect(left[:value][:string].str).to eql("jane")
      expect(right[:field].str).to eql("surname")
      expect(right[:filter_op].str).to eql("neq")
      expect(right[:value][:string].str).to eql("doe")
    end

    context "value parenthesization" do
      it "correctly parses different formats" do
        expect(parse("id eq(42)")[:exp][:value][:int].str).to eql("42")
        expect(parse("id eq (42)")[:exp][:value][:int].str).to eql("42")
        expect(parse("id eq ((42))")[:exp][:value][:int].str).to eql("42")
        expect(parse("id eq ( (   ( 42)) )")[:exp][:value][:int].str).to eql("42")
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
    end
  end
end

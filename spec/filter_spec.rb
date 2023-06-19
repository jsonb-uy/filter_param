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
          expect(parse(expression)[:field].str).to eql(column)
        end
      end
    end

    context "with an unrecognized operation" do
      it "raises an error" do
        expect { parse("name equals 1") }.to raise_error(Parslet::ParseFailed)
        expect { parse("name = 1") }.to raise_error(Parslet::ParseFailed)
        expect { parse("name + 1") }.to raise_error(Parslet::ParseFailed)
      end
    end

    it "parses :eq operation" do
      expect(parse("name eq 'john'")[:filter_op].str).to eql("eq")
      expect(parse("name eq('john')")[:filter_op].str).to eql("eq")
      expect(parse("name   eq  'john'")[:filter_op].str).to eql("eq")
    end

    it "parses :neq operation" do
      expect(parse("name neq 'john'")[:filter_op].str).to eql("neq")
      expect(parse("name neq('john')")[:filter_op].str).to eql("neq")
      expect(parse("name  neq  'john'")[:filter_op].str).to eql("neq")
    end

    context "when value is null" do
      it "parses the value" do
        expect(parse("name eq null")[:null_literal].str).to eql("null")
        expect(parse("name eq (null)")[:null_literal].str).to eql("null")
        expect(parse("name eq(null)")[:null_literal].str).to eql("null")
      end
    end

    context "when value is a string" do
      it "parses the value" do
        expect(parse("name  eq 'john'")[:string_literal].str).to eql("john")
        expect(parse("name eq \"john\"")[:string_literal].str).to eql("john")
        expect(parse("name eq (\"john\")")[:string_literal].str).to eql("john")
        expect(parse("name eq (  (  \"john\" ))")[:string_literal].str).to eql("john")
        expect(parse("name eq( (('john' )))")[:string_literal].str).to eql("john")
        expect(parse("name eq ('john')")[:string_literal].str).to eql("john")
        expect(parse("name eq('john')")[:string_literal].str).to eql("john")
      end
    end

    context "with :or operation" do
      it "parses the expression correctly" do
        expect(parse("name eq 'john' or name eq 'jane'")[:string_literal].str).to eql("john")
      end
    end
  end
end

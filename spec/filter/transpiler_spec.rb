# frozen_string_literal: true

RSpec.describe FilterParam::Filter::Transpiler do
  subject(:transpiler) { new_transpiler }

  def new_transpiler(definition = nil)
    definition ||= FilterParam::Definition.new.fields(
      :first_name,
      :birth_date,
      :member_since,
      :balance
    )

    described_class.new(definition)
  end

  describe "#transpile" do
    context "with blank expression" do
      it "returns nil" do
        expect(transpiler.transpile!("     ")).to be_nil
        expect(transpiler.transpile!("")).to be_nil
        expect(transpiler.transpile!(nil)).to be_nil
      end
    end

    context "with an expression with unexpected token" do
      it "raises an error" do
        expect do
          transpiler.transpile!("first_name eq 'John' 1")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq 1 'John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq a 'John'")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    context "with an expression with missing parenthesis" do
      it "raises an error" do
        expect do
          transpiler.transpile!("first_name eq ('John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq 'John')")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("((first_name eq 'John')")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    context "with an expression with missing quote" do
      it "raises an error" do
        expect do
          transpiler.transpile!("first_name eq 'John")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq \"John")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq John\"")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("first_name eq John")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    context "with an expression with invalid identifier format" do
      it "raises an error" do
        expect do
          transpiler.transpile!("1dentifer eq 'John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("'first_name' eq 'John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("----' eq 'John'")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    context "with an expression with unrecognized operation" do
      it "raises an error" do
        expect do
          transpiler.transpile!("1dentifer equals 'John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("'first_name' = 'John'")
        end.to raise_error(FilterParam::ParseError)
      end
    end
  end
end

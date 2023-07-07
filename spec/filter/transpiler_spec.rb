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

    context "with unexpected token" do
      it "raises parse error" do
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

    context "with missing parenthesis" do
      it "raises parse error" do
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

    context "with missing quote" do
      it "raises parse error" do
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

    context "with invalid field format" do
      it "raises parse error" do
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

    context "with non-whitelisted field" do
      it "raises unpermitted field error" do
        expect do
          transpiler.transpile!("last_name eq 'Doe'")
        end.to raise_error(FilterParam::UnpermittedField)
      end
    end

    context "with unrecognized operation" do
      it "raises parse error" do
        expect do
          transpiler.transpile!("1dentifer equals 'John'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("'first_name' = 'John'")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    xcontext "with invalid date month day" do
      it "raises parse error" do
        expect do
          transpiler.transpile!("birth_date eq '2023-02-31'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("birth_date eq '2023-09-31'")
        end.to raise_error(FilterParam::ParseError)

        expect do
          transpiler.transpile!("birth_date eq '2023-06-31'")
        end.to raise_error(FilterParam::ParseError)
      end
    end

    xcontext "with :eq operation" do
    end
  end
end

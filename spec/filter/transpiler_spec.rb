# frozen_string_literal: true

RSpec.describe FilterParam::Filter::Transpiler do
  subject(:transpiler) { new_transpiler }

  def new_transpiler(definition = nil)
    definition ||= FilterParam::Definition.new
                                          .field(:first_name)
                                          .field(:birth_date, type: :date)
                                          .field(:member_since, type: :datetime)
                                          .field(:balance, type: :decimal)
                                          .field(:age, type: :int)

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

    context "with invalid iso8601 date " do
      it "raises parse error" do
        expect do
          transpiler.transpile!("birth_date eq '2023-02-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-09-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-06-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '06-31-2023'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-00-00'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)
      end
    end

    context "with invalid iso8601 date" do
      it "raises parse error" do
        expect do
          transpiler.transpile!("birth_date eq '2023-02-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-09-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-06-31'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '06-31-2023'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-00-00'")
        end.to raise_error(FilterParam::ParseError, /Invalid Date/)
      end
    end

    context "with invalid iso8601 datetime" do
      it "raises parse error" do
        expect do
          transpiler.transpile!("member_since eq '2023-02-31T08:30:01.999Z'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-13-15T15:30:01.999'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-02-15T25:30:01.999'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-02-15T23:60:01.999'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-00-10'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-11-00'")
        end.to raise_error(FilterParam::ParseError, /Invalid Datetime/)
      end
    end

    xcontext "with :eq operation" do
    end
  end
end

# frozen_string_literal: true

RSpec.describe FilterParam::Filter::Transpiler do
  subject(:transpiler) { new_transpiler }

  def new_transpiler(definition = nil)
    definition ||= FilterParam::Definition.new
                                          .field(:name, rename: :first_name)
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

    context "with :eq operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name eq null")).to eql("first_name IS NULL")
        expect(transpiler.transpile!("name eq 'John'")).to eql("first_name = 'John'")
        expect(transpiler.transpile!("age eq 100")).to eql("age = 100")
        expect(transpiler.transpile!("balance eq 9182841.1923")).to eql("balance = 9182841.1923")
        expect(transpiler.transpile!("birth_date eq '2023-04-01'")).to eql("birth_date = '2023-04-01'")
        expect(transpiler.transpile!("member_since eq '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since = '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since eq '2023-04-01T22:30:05.019+08:00'")).to eql("member_since = '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :neq operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name neq null")).to eql("first_name IS NOT NULL")
        expect(transpiler.transpile!("name neq 'John'")).to eql("first_name != 'John'")
        expect(transpiler.transpile!("age neq 100")).to eql("age != 100")
        expect(transpiler.transpile!("balance neq 9182841.1923")).to eql("balance != 9182841.1923")
        expect(transpiler.transpile!("birth_date neq '2023-04-01'")).to eql("birth_date != '2023-04-01'")
        expect(transpiler.transpile!("member_since neq '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since neq '2023-04-01T22:30:05.019+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019000'")
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe FilterParam::Transpiler do
  subject(:transpiler) { new_transpiler }

  def new_transpiler(definition = nil)
    definition ||= FilterParam::Definition.new
                                          .field(:name, rename: :first_name)
                                          .field(:first_name)
                                          .field(:birth_date, type: :date)
                                          .field(:member_since, type: :datetime)
                                          .field(:balance, type: :decimal)
                                          .field(:age, type: :integer)
                                          .field(:active, type: :boolean)

    described_class.new(definition)
  end

  describe "#transpile!" do
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
        end.to raise_error(FilterParam::UnknownField)
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

    context "with invalid integer value" do
      it "raises an InvalidLiteral error" do
        expect do
          transpiler.transpile!("age eq 'ten'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid Integer/)

        expect do
          transpiler.transpile!("age eq '0.10'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid Integer/)
      end
    end

    context "with invalid decimal value" do
      it "raises an InvalidLiteral error" do
        expect do
          transpiler.transpile!("balance eq 'ten'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid Decimal/)

        expect do
          transpiler.transpile!("balance eq '0.10e'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid Decimal/)
      end
    end

    context "with invalid iso8601 date " do
      it "raises an InvalidLiteral error" do
        expect do
          transpiler.transpile!("birth_date eq '2023-02-31'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-09-31'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-06-31'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Date/)

        expect do
          transpiler.transpile!("birth_date eq '06-31-2023'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Date/)

        expect do
          transpiler.transpile!("birth_date eq '2023-00-00'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Date/)
      end
    end

    context "with invalid iso8601 datetime" do
      it "raises an InvalidLiteral error" do
        expect do
          transpiler.transpile!("member_since eq '2023-02-31T08:30:01.999Z'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-13-15T15:30:01.999'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-02-15T25:30:01.999'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-02-15T23:60:01.999'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-00-10'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)

        expect do
          transpiler.transpile!("member_since eq '2023-11-00'")
        end.to raise_error(FilterParam::InvalidLiteral, /Invalid ISO8601 Datetime/)
      end
    end

    context "with :not operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("not name eq null")).to eql("first_name IS NOT NULL")
        expect(transpiler.transpile!("not name pr")).to eql("(first_name IS NULL OR TRIM(first_name) = '')")
        expect(transpiler.transpile!("not active pr")).to eql("active IS NULL")
        expect(transpiler.transpile!("not active eq true")).to eql("active != 1").or eql("active != true")
        expect(transpiler.transpile!("not active eq false")).to eql("active != 0").or eql("active != false")
        expect(transpiler.transpile!("not name eq 'John'")).to eql("first_name != 'John'")
        expect(transpiler.transpile!("not age pr")).to eql("age IS NULL")
        expect(transpiler.transpile!("not age eq 100")).to eql("age != 100")
        expect(transpiler.transpile!("not(age eq 100)")).to eql("NOT (age = 100)")
        expect(transpiler.transpile!("not balance pr")).to eql("balance IS NULL")
        expect(transpiler.transpile!("not balance eq 9182841.1923")).to eql("balance != 9182841.1923")
        expect(transpiler.transpile!("not birth_date pr")).to eql("birth_date IS NULL")
        expect(transpiler.transpile!("not birth_date eq '2023-04-01'")).to eql("birth_date != '2023-04-01'")
        expect(transpiler.transpile!("not member_since pr")).to eql("member_since IS NULL")
        expect(transpiler.transpile!("not member_since eq '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("not member_since eq '2023-04-01T22:30:05.019+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :eq operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name eq null")).to eql("first_name IS NULL")
        expect(transpiler.transpile!("active eq true")).to eql("active = 1").or eql("active = true")
        expect(transpiler.transpile!("active eq false")).to eql("active = 0").or eql("active = false")
        expect(transpiler.transpile!("name eq 'John'")).to eql("first_name = 'John'")
        expect(transpiler.transpile!("age eq 100")).to eql("age = 100")
        expect(transpiler.transpile!("balance eq 9182841.1923")).to eql("balance = 9182841.1923")
        expect(transpiler.transpile!("birth_date eq '2023-04-01'")).to eql("birth_date = '2023-04-01'")
        expect(transpiler.transpile!("member_since eq '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since = '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since eq '2023-04-01T22:30:05.019+08:00'")).to eql("member_since = '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :eq_ci operation" do
      it "transpiles to SQL correctly" do
        expect { transpiler.transpile!("name eq_ci null") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active eq_ci true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active eq_ci false") }.to raise_error(FilterParam::InvalidLiteral)
        expect(transpiler.transpile!("name eq_ci 'John'")).to eql("lower(first_name) = 'john'")
        expect { transpiler.transpile!("age eq_ci 100") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("balance eq_ci 9182841.1923") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("birth_date eq_ci '2023-04-01'") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("member_since eq_ci '2023-04-01T22:30:05.019254+08:00'") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("member_since eq_ci '2023-04-01T22:30:05.019+08:00'") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "with :neq operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name neq null")).to eql("first_name IS NOT NULL")
        expect(transpiler.transpile!("active neq true")).to eql("active != 1").or eql("active != TRUE")
        expect(transpiler.transpile!("active neq false")).to eql("active != 0").or eql("active != FALSE")
        expect(transpiler.transpile!("name neq 'John'")).to eql("first_name != 'John'")
        expect(transpiler.transpile!("age neq 100")).to eql("age != 100")
        expect(transpiler.transpile!("balance neq 9182841.1923")).to eql("balance != 9182841.1923")
        expect(transpiler.transpile!("birth_date neq '2023-04-01'")).to eql("birth_date != '2023-04-01'")
        expect(transpiler.transpile!("member_since neq '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since neq '2023-04-01T22:30:05.019+08:00'")).to eql("member_since != '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :lt operation" do
      it "transpiles to SQL correctly" do
        expect { transpiler.transpile!("name lt null") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active lt true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active lt false") }.to raise_error(FilterParam::InvalidLiteral)
        expect(transpiler.transpile!("name lt 'John'")).to eql("first_name < 'John'")
        expect(transpiler.transpile!("age lt 100")).to eql("age < 100")
        expect(transpiler.transpile!("balance lt 9182841.1923")).to eql("balance < 9182841.1923")
        expect(transpiler.transpile!("birth_date lt '2023-04-01'")).to eql("birth_date < '2023-04-01'")
        expect(transpiler.transpile!("member_since lt '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since < '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since lt '2023-04-01T22:30:05.019+08:00'")).to eql("member_since < '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :le operation" do
      it "transpiles to SQL correctly" do
        expect { transpiler.transpile!("name le null") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active le true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active le false") }.to raise_error(FilterParam::InvalidLiteral)
        expect(transpiler.transpile!("name le 'John'")).to eql("first_name <= 'John'")
        expect(transpiler.transpile!("age le 100")).to eql("age <= 100")
        expect(transpiler.transpile!("balance le 9182841.1923")).to eql("balance <= 9182841.1923")
        expect(transpiler.transpile!("birth_date le '2023-04-01'")).to eql("birth_date <= '2023-04-01'")
        expect(transpiler.transpile!("member_since le '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since <= '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since le '2023-04-01T22:30:05.019+08:00'")).to eql("member_since <= '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :gt operation" do
      it "transpiles to SQL correctly" do
        expect { transpiler.transpile!("name gt null") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active gt true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active gt false") }.to raise_error(FilterParam::InvalidLiteral)
        expect(transpiler.transpile!("name gt 'John'")).to eql("first_name > 'John'")
        expect(transpiler.transpile!("age gt 100")).to eql("age > 100")
        expect(transpiler.transpile!("balance gt 9182841.1923")).to eql("balance > 9182841.1923")
        expect(transpiler.transpile!("birth_date gt '2023-04-01'")).to eql("birth_date > '2023-04-01'")
        expect(transpiler.transpile!("member_since gt '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since > '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since gt '2023-04-01T22:30:05.019+08:00'")).to eql("member_since > '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :ge operation" do
      it "transpiles to SQL correctly" do
        expect { transpiler.transpile!("name ge null") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active ge true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active ge false") }.to raise_error(FilterParam::InvalidLiteral)
        expect(transpiler.transpile!("name ge 'John'")).to eql("first_name >= 'John'")
        expect(transpiler.transpile!("age ge 100")).to eql("age >= 100")
        expect(transpiler.transpile!("balance ge 9182841.1923")).to eql("balance >= 9182841.1923")
        expect(transpiler.transpile!("birth_date ge '2023-04-01'")).to eql("birth_date >= '2023-04-01'")
        expect(transpiler.transpile!("member_since ge '2023-04-01T22:30:05.019254+08:00'")).to eql("member_since >= '2023-04-01 14:30:05.019254'")
        expect(transpiler.transpile!("member_since ge '2023-04-01T22:30:05.019+08:00'")).to eql("member_since >= '2023-04-01 14:30:05.019000'")
      end
    end

    context "with :pr operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name pr")).to eql("(first_name IS NOT NULL AND TRIM(first_name) != '')")
        expect(transpiler.transpile!("active pr")).to eql("active IS NOT NULL")
        expect(transpiler.transpile!("age pr")).to eql("age IS NOT NULL")
        expect(transpiler.transpile!("balance pr")).to eql("balance IS NOT NULL")
        expect(transpiler.transpile!("birth_date pr")).to eql("birth_date IS NOT NULL")
        expect(transpiler.transpile!("member_since pr")).to eql("member_since IS NOT NULL")
      end
    end

    context "with :sw operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name sw 'Jo'")).to eql("first_name LIKE 'Jo%'")
        expect { transpiler.transpile!("active sw true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active sw false") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("age sw 100") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("balance sw 193.12") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("birth_date sw '2023-04-01'") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("member_since sw '2023-04-01T22:30:05.019+08:00'") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "with :ew operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name ew 'Jo'")).to eql("first_name LIKE '%Jo'")
        expect { transpiler.transpile!("active ew true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active ew false") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("age ew 100") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("balance ew 193.12") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("birth_date ew '2023-04-01'") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("member_since ew '2023-04-01T22:30:05.019+08:00'") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "with :co operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("name co 'oh'")).to eql("first_name LIKE '%oh%'")
        expect { transpiler.transpile!("active co true") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("active co false") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("age co 100") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("balance co 193.12") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("birth_date co '2023-04-01'") }.to raise_error(FilterParam::InvalidLiteral)
        expect { transpiler.transpile!("member_since co '2023-04-01T22:30:05.019+08:00'") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "with :and operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("age lt 50 and name eq 'John'")).to eql("age < 50 AND first_name = 'John'")
        expect(transpiler.transpile!("age lt 50 and (name eq 'John')")).to eql("age < 50 AND (first_name = 'John')")
        expect(transpiler.transpile!("(age lt 50) and name eq 'John'")).to eql("(age < 50) AND first_name = 'John'")
        expect(transpiler.transpile!("(age lt 50 and name eq 'John')")).to eql("(age < 50 AND first_name = 'John')")
      end
    end

    context "with :or operation" do
      it "transpiles to SQL correctly" do
        expect(transpiler.transpile!("age lt 50 or name eq 'John'")).to eql("age < 50 OR first_name = 'John'")
        expect(transpiler.transpile!("age lt 50 or (name eq 'John')")).to eql("age < 50 OR (first_name = 'John')")
        expect(transpiler.transpile!("(age lt 50) or name eq 'John'")).to eql("(age < 50) OR first_name = 'John'")
        expect(transpiler.transpile!("(age lt 50 or name eq 'John')")).to eql("(age < 50 OR first_name = 'John')")
      end
    end
  end
end

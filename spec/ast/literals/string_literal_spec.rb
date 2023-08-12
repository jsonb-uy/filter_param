RSpec.describe FilterParam::AST::Literals::String do
  subject(:string_literal) { described_class.new("some string") }

  describe ".new" do
    it "returns an instance" do
      expect(described_class.new("foo bar baz")).to be_a(described_class)
    end
  end

  describe "#data_type" do
    it "returns :string" do
      expect(string_literal.data_type).to eql(:string)
    end
  end

  describe "#value" do
    it "returns a string value" do
      expect(string_literal.value).to eql("some string")
      expect(string_literal.value).to be_a(::String)
    end
  end

  describe "#type_cast" do
    context "when to :null" do
      it "raises an error" do
        expect { string_literal.type_cast(:null) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :string" do
      it "returns the same string literal" do
        expect(string_literal.type_cast(:string)).to be(string_literal)
        expect(string_literal.data_type).to eql(:string)
      end
    end

    context "when to :boolean" do
      context "when value is true" do
        it "returns a TRUE boolean literal" do
          boolean_literal1 = described_class.new("TRUE").type_cast(:boolean)
          expect(boolean_literal1.data_type).to eql(:boolean)
          expect(boolean_literal1.value).to be(true)

          boolean_literal2 = described_class.new("true").type_cast(:boolean)
          expect(boolean_literal2.data_type).to eql(:boolean)
          expect(boolean_literal2.value).to be(true)

          boolean_literal3 = described_class.new("True").type_cast(:boolean)
          expect(boolean_literal3.data_type).to eql(:boolean)
          expect(boolean_literal3.value).to be(true)
        end
      end

      context "when value is not true" do
        it "returns a FALSE boolean literal" do
          boolean_literal1 = described_class.new("false").type_cast(:boolean)
          expect(boolean_literal1.data_type).to eql(:boolean)
          expect(boolean_literal1.value).to be(false)

          boolean_literal2 = described_class.new("FALSE").type_cast(:boolean)
          expect(boolean_literal2.data_type).to eql(:boolean)
          expect(boolean_literal2.value).to be(false)

          boolean_literal3 = described_class.new("False").type_cast(:boolean)
          expect(boolean_literal3.data_type).to eql(:boolean)
          expect(boolean_literal3.value).to be(false)

          boolean_literal4 = described_class.new("Some value").type_cast(:boolean)
          expect(boolean_literal4.data_type).to eql(:boolean)
          expect(boolean_literal4.value).to be(false)
        end
      end
    end

    context "when to :integer" do
      context "when value is parseable to integer" do
        it "returns an integer literal" do
          int_literal1 = described_class.new("100").type_cast(:integer)
          int_literal2 = described_class.new("0").type_cast(:integer)
          int_literal3 = described_class.new("42").type_cast(:integer)

          expect(int_literal1.data_type).to eql(:integer)
          expect(int_literal1.value).to eql(100)

          expect(int_literal2.data_type).to eql(:integer)
          expect(int_literal2.value).to eql(0)

          expect(int_literal3.data_type).to eql(:integer)
          expect(int_literal3.value).to eql(42)
        end
      end

      context "when value is not parseable to integer" do
        it "raises an error" do
          expect { string_literal.type_cast(:integer) }.to raise_error(FilterParam::InvalidLiteral)
        end
      end
    end

    context "when to :decimal" do
      context "when value is parseable to decimal" do
        it "returns an integer literal" do
          decimal_literal1 = described_class.new("100.012").type_cast(:decimal)
          decimal_literal2 = described_class.new("3.1416").type_cast(:decimal)
          decimal_literal3 = described_class.new("42").type_cast(:decimal)

          expect(decimal_literal1.data_type).to eql(:decimal)
          expect(decimal_literal1.value).to eql(BigDecimal("100.012"))

          expect(decimal_literal2.data_type).to eql(:decimal)
          expect(decimal_literal2.value).to eql(BigDecimal("3.1416"))

          expect(decimal_literal3.data_type).to eql(:decimal)
          expect(decimal_literal3.value).to eql(BigDecimal("42.0"))
        end
      end

      context "when value is not parseable to decimal" do
        it "raises an error" do
          expect { string_literal.type_cast(:decimal) }.to raise_error(FilterParam::InvalidLiteral)
        end
      end
    end

    context "when to :date" do
      context "when value is parseable to an ISO 8601 date" do
        it "returns a date literal" do
          date_literal = described_class.new("2023-12-01").type_cast(:date)
          expect(date_literal.data_type).to eql(:date)
          expect(date_literal.value).to eql(Date.parse("2023-12-01"))
        end
      end

      context "when value is not parseable to an ISO 8601 date" do
        it "raises an error" do
          expect { string_literal.type_cast(:date) }.to raise_error(FilterParam::InvalidLiteral)
        end
      end
    end

    context "when to :datetime" do
      context "when value is parseable to an ISO 8601 datetime" do
        it "returns a datetime literal" do
          datetime_literal = described_class.new("2023-12-01T05:06:08.991+08:00").type_cast(:datetime)
          expect(datetime_literal.data_type).to eql(:datetime)
          expect(datetime_literal.value).to eql(DateTime.parse("2023-12-01T05:06:08.991+08:00"))
        end
      end

      context "when value is not parseable to an ISO 8601 datetime" do
        it "raises an error" do
          expect { string_literal.type_cast(:datetime) }.to raise_error(FilterParam::InvalidLiteral)
        end
      end
    end
  end
end

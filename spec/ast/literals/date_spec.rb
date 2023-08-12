RSpec.describe FilterParam::AST::Literals::Date do
  subject(:date_literal) { described_class.new("2023-12-01") }

  describe ".new" do
    it "returns an instance" do
      expect(described_class.new("2023-12-14")).to be_a(described_class)
    end

    context "when given value is not parseable to an ISO 8601 date" do
      it "raises an error" do
        expect { described_class.new("12-14-2023") }.to raise_error(FilterParam::InvalidLiteral)
        expect { described_class.new("February 26, 1986") }.to raise_error(FilterParam::InvalidLiteral)
        expect { described_class.new("12") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end

  describe "#data_type" do
    it "returns :date" do
      expect(date_literal.data_type).to eql(:date)
    end
  end

  describe "#value" do
    it "returns a date value" do
      expect(date_literal.value).to eql(Date.parse("2023-12-01"))
      expect(date_literal.value).to be_a(Date)
    end
  end

  describe "#type_cast" do
    context "when to :null" do
      it "raises an error" do
        expect { date_literal.type_cast(:null) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :string" do
      it "returns a string literal" do
        string_literal = date_literal.type_cast(:string)
        expect(string_literal.data_type).to eql(:string)
        expect(string_literal.value).to eql("2023-12-01")
      end
    end

    context "when to :boolean" do
      it "raises an error" do
        expect { date_literal.type_cast(:boolean) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :integer" do
      it "raises an error" do
        expect { date_literal.type_cast(:integer) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :decimal" do
      it "raises an error" do
        expect { date_literal.type_cast(:integer) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :date" do
      it "returns the same date literal" do
        expect(date_literal.type_cast(:date)).to be(date_literal)
        expect(date_literal.data_type).to eql(:date)
      end
    end

    context "when to :datetime" do
      it "returns a datetime literal" do
        datetime_literal = date_literal.type_cast(:datetime)
        expect(datetime_literal.data_type).to eql(:datetime)
        expect(datetime_literal.value).to eql(DateTime.parse("2023-12-01T00:00:00.000Z"))
      end
    end
  end
end

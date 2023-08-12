RSpec.describe FilterParam::AST::Literals::Decimal do
  subject(:decimal_literal) { described_class.new("3.1416") }

  describe ".new" do
    it "returns an instance" do
      expect(described_class.new("42.01")).to be_a(described_class)
    end

    context "when given value is not parseable to decimal" do
      it "raises an error" do
        expect { described_class.new("some value") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end

  describe "#data_type" do
    it "returns :decimal" do
      expect(decimal_literal.data_type).to eql(:decimal)
    end
  end

  describe "#value" do
    it "returns a big decimal value" do
      expect(decimal_literal.value).to eql(BigDecimal("3.1416"))
      expect(decimal_literal.value).to be_a(BigDecimal)
    end
  end

  describe "#type_cast" do
    context "when to :null" do
      it "raises an error" do
        expect { decimal_literal.type_cast(:null) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :string" do
      it "returns a string literal" do
        string_literal = decimal_literal.type_cast(:string)
        expect(string_literal.data_type).to eql(:string)
        expect(string_literal.value).to eql("3.1416")
      end
    end

    context "when to :boolean" do
      context "when value is not 0.0" do
        it "returns a TRUE boolean literal" do
          boolean_literal1 = described_class.new("0.01").type_cast(:boolean)
          expect(boolean_literal1.data_type).to eql(:boolean)
          expect(boolean_literal1.value).to be(true)

          boolean_literal2 = described_class.new("1.0").type_cast(:boolean)
          expect(boolean_literal2.data_type).to eql(:boolean)
          expect(boolean_literal2.value).to be(true)
        end
      end

      context "when value is 0.0" do
        it "returns a FALSE boolean literal" do
          boolean_literal = described_class.new("0.0").type_cast(:boolean)
          expect(boolean_literal.data_type).to eql(:boolean)
          expect(boolean_literal.value).to be(false)
        end
      end
    end

    context "when to :integer" do
      it "returns an integer literal" do
        int_literal = decimal_literal.type_cast(:integer)
        expect(int_literal.data_type).to eql(:integer)
        expect(int_literal.value).to eql(3)
      end
    end

    context "when to :decimal" do
      it "returns the same decimal literal" do
        expect(decimal_literal.type_cast(:decimal)).to be(decimal_literal)
        expect(decimal_literal.data_type).to eql(:decimal)
      end
    end

    context "when to :date" do
      it "raises an error" do
        expect { decimal_literal.type_cast(:date) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :datetime" do
      it "raises an error" do
        expect { decimal_literal.type_cast(:datetime) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end
end

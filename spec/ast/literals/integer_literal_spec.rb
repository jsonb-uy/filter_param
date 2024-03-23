RSpec.describe FilterParam::AST::Literals::Integer do
  subject(:int_literal) { described_class.new("42") }

  describe ".new" do
    it "returns an instance" do
      expect(described_class.new("100")).to be_a(described_class)
    end

    context "when given value is not parseable to integer" do
      it "raises an error" do
        expect { described_class.new("some value") }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end

  describe "#data_type" do
    it "returns :integer" do
      expect(int_literal.data_type).to eql(:integer)
    end
  end

  describe "#value" do
    it "returns integer value" do
      expect(described_class.new("42").value).to eql(42)
      expect(described_class.new("0000").value).to eql(0)
      expect(described_class.new("-1").value).to eql(-1)
      expect(described_class.new("1024.85").value).to eql(1024)
      expect(described_class.new("0.85").value).to eql(0)
    end
  end

  describe "#type_cast" do
    context "when to :null" do
      it "raises an error" do
        expect { int_literal.type_cast(:null) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :string" do
      it "returns a string literal" do
        string_literal = int_literal.type_cast(:string)
        expect(string_literal.data_type).to eql(:string)
        expect(string_literal.value).to eql("42")
      end
    end

    context "when to :boolean" do
      context "when value is not 0" do
        it "returns a TRUE boolean literal" do
          boolean_literal1 = described_class.new("1").type_cast(:boolean)
          expect(boolean_literal1.data_type).to eql(:boolean)
          expect(boolean_literal1.value).to be(true)

          boolean_literal2 = described_class.new("2").type_cast(:boolean)
          expect(boolean_literal2.data_type).to eql(:boolean)
          expect(boolean_literal2.value).to be(true)
        end
      end

      context "when value is 0" do
        it "returns a FALSE boolean literal" do
          boolean_literal = described_class.new(0).type_cast(:boolean)
          expect(boolean_literal.data_type).to eql(:boolean)
          expect(boolean_literal.value).to be(false)
        end
      end
    end

    context "when to :integer" do
      it "returns the same integer literal" do
        expect(int_literal.type_cast(:integer)).to be(int_literal)
        expect(int_literal.data_type).to eql(:integer)
      end
    end

    context "when to :decimal" do
      it "returns a decimal literal" do
        decimal_literal1 = described_class.new("10").type_cast(:decimal)
        expect(decimal_literal1.data_type).to eql(:decimal)
        expect(decimal_literal1.value).to eql(10.0)

        decimal_literal2 = described_class.new("0").type_cast(:decimal)
        expect(decimal_literal2.data_type).to eql(:decimal)
        expect(decimal_literal2.value).to eql(0.0)
      end
    end

    context "when to :date" do
      it "raises an error" do
        expect { int_literal.type_cast(:date) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :datetime" do
      it "raises an error" do
        expect { int_literal.type_cast(:datetime) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end
end

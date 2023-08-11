RSpec.describe FilterParam::AST::Literals::Boolean do
  subject(:true_literal) { described_class::TRUE }
  subject(:false_literal) { described_class::FALSE }

  describe ".new" do
    it "is not exposed" do
      expect { described_class.new }.to raise_error
    end
  end

  describe "::TRUE" do
    it "returns a singleton boolean instance with value 'true'" do
      expect(described_class::TRUE).to be_a(described_class)
      expect(described_class::TRUE).to eql(described_class::TRUE)
    end
  end

  describe "#data_type" do
    it "returns :boolean" do
      expect(true_literal.data_type).to eql(:boolean)
    end
  end

  describe "#type_cast" do
    context "when to :string" do
      context "when true" do
        it "returns a string literal with value 'true'" do
          string_literal = true_literal.type_cast(:string)
          expect(string_literal.data_type).to eql(:string)
          expect(string_literal.value).to eql("true")
        end
      end

      context "when false" do
        it "returns a string literal with value 'false'" do
          string_literal = false_literal.type_cast(:string)
          expect(string_literal.data_type).to eql(:string)
          expect(string_literal.value).to eql("false")
        end
      end
    end

    context "when to :boolean" do
      it "returns the same boolean instance" do
        expect(false_literal.type_cast(:boolean)).to eql(false_literal)
        expect(true_literal.type_cast(:boolean)).to eql(true_literal)
      end
    end

    context "when to :integer" do
      context "when true" do
        it "returns an integer literal with value '1'" do
          int_literal = true_literal.type_cast(:integer)
          expect(int_literal.data_type).to eql(:integer)
          expect(int_literal.value).to eql(1)
        end
      end

      context "when false" do
        it "returns a integer literal with value '0'" do
          int_literal = false_literal.type_cast(:integer)
          expect(int_literal.data_type).to eql(:integer)
          expect(int_literal.value).to eql(0)
        end
      end
    end

    context "when to :decimal" do
      context "when true" do
        it "returns an decimal literal with value '1'" do
          int_literal = true_literal.type_cast(:decimal)
          expect(int_literal.data_type).to eql(:decimal)
          expect(int_literal.value).to eql(1.0)
        end
      end

      context "when false" do
        it "returns a decimal literal with value '0'" do
          int_literal = false_literal.type_cast(:decimal)
          expect(int_literal.data_type).to eql(:decimal)
          expect(int_literal.value).to eql(0.0)
        end
      end
    end

    context "when to :date" do
      it "raises an error" do
        expect { true_literal.type_cast(:date) }.to raise_error(FilterParam::InvalidLiteral)
        expect { false_literal.type_cast(:date) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end

    context "when to :datetime" do
      it "raises an error" do
        expect { true_literal.type_cast(:datetime) }.to raise_error(FilterParam::InvalidLiteral)
        expect { false_literal.type_cast(:datetime) }.to raise_error(FilterParam::InvalidLiteral)
      end
    end
  end
end

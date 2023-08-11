RSpec.describe FilterParam::AST::Literals::Null do
  subject(:null_literal) { described_class.instance }

  describe ".new" do
    it "is not exposed" do
      expect { described_class.new }.to raise_error
    end
  end

  describe ".instance" do
    it "returns a singleton instance" do
      expect(described_class.instance).to be_a(described_class)
      expect(described_class.instance).to eql(described_class.instance)
    end
  end

  describe "#data_type" do
    it "returns :null" do
      expect(null_literal.data_type).to eql(:null)
    end
  end

  describe "#value" do
    it "returns nil" do
      expect(null_literal.value).to be_nil
    end
  end

  describe "#type_cast" do
    context "when to :string" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:string)).to be(null_literal)
        expect(null_literal.data_type).to eql(:null)
      end
    end

    context "when to :boolean" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:boolean)).to eql(null_literal)
      end
    end

    context "when to :integer" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:integer)).to eql(null_literal)
      end
    end

    context "when to :decimal" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:decimal)).to eql(null_literal)
      end
    end

    context "when to :date" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:date)).to eql(null_literal)
      end
    end

    context "when to :datetime" do
      it "returns the same null instance" do
        expect(null_literal.type_cast(:datetime)).to eql(null_literal)
      end
    end
  end
end

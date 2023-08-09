# frozen_string_literal: true

RSpec.describe FilterParam::AST::Operators::Operator do
  let(:operator_class) { Class.new(FilterParam::AST::Operators::Operator) }

  describe ".register" do
    it "registers an operator" do
      expect(described_class.register("op", operator_class)).to eq(operator_class)
      expect(described_class.for("op") < described_class).to be(true)
    end
  end

  describe ".reset_registry!" do
    it "clears the operator registry" do
      described_class.register("op2", operator_class)

      described_class.reset_registry!

      expect(described_class.for("op")).to be_nil
    end
  end

  describe ".for" do
    it "returns the operator class given the tag" do
      described_class.register("op3", operator_class)

      expect(described_class.for("op3")).to eql(operator_class)
    end
  end
end

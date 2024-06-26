# frozen_string_literal: true

RSpec.describe FilterParam::Operator do
  let(:operator_class) do
    class_double("MyOperator", tag: "op")
  end

  describe ".register" do
    it "registers an operator" do
      expect(described_class.register(operator_class)).to eq(operator_class)
    end
  end

  describe ".for" do
    it "returns the operator class given the tag" do
      described_class.register(operator_class)

      expect(described_class.for("op")).to eql(operator_class)
    end
  end
end

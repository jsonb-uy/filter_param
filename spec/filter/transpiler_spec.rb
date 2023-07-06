# frozen_string_literal: true

RSpec.describe FilterParam::Filter::Transpiler do
  subject(:transpiler) { new_transpiler }

  def new_transpiler(definition = nil)
    definition ||= FilterParam::Definition.new.fields(
                    :first_name,
                    :birth_date,
                    :member_since,
                    :balance)

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
      it "raises an error" do
        expect do
          transpiler.transpile!("first_name eq 'John' 1")
          transpiler.transpile!("first_name eq 'John'a")
        end.to raise_error(FilterParam::ParseError)
      end
    end
  end
end

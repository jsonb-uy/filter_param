# frozen_string_literal: true

RSpec.describe FilterParam do
  describe ".define" do
    context "with column definition block" do
      it "creates a Definition instance" do
        definition = FilterParam.define do
          field :email
          field :first_name
        end

        expect(definition).to be_a(FilterParam::Definition)
      end
    end

    context "with no block given" do
      it "raises an error" do
        expect { FilterParam.define }.to raise_error(ArgumentError)
      end
    end
  end
end

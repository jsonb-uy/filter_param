# frozen_string_literal: true

RSpec.describe FilterParam::Definition do
  subject(:definition) { described_class.new }

  describe "#define" do
    context "with fields defined" do
      before do
        definition.define do
          fields :first_name, :last_name, some_option: "someval"
          field :email
        end
      end

      it "defines the whitelisted filter fields and their configuration" do
        expect(definition.fields_hash).to eql(
          {
            "email" => {},
            "first_name" => { some_option: "someval" },
            "last_name" => { some_option: "someval" }
          }
        )
      end
    end

    context "with no fields defined" do
      it "raises an error" do
        expect { definition.define }.to raise_error(ArgumentError)
      end
    end
  end

  xdescribe "#field" do
    it "whitelists a sort field and sets its default options" do
      definition.field(:email, nulls: :first)
      definition.field(:first_name, nulls: :last)
      definition.field(:last_name)

      expect(definition.fields_hash).to eql(
        {
          "email" => { nulls: :first },
          "first_name" => { nulls: :last },
          "last_name" => {}
        }
      )
    end

    it "ignores blank field name" do
      definition.field("")
      definition.field(nil)

      expect(definition.fields_hash).to be_empty
    end

    it "returns the same Field instance" do
      expect(definition.field(:name)).to eql(definition)
    end

    context "with String :rename option value" do
      it "sets the :rename value" do
        definition.field(:last_name, rename: "surname")

        expect(definition.fields_hash).to eql(
          {
            "last_name" => { rename: "surname" }
          }
        )
      end
    end

    context "with Proc :rename option value" do
      it "sets the :rename value to the transformed :name" do
        definition.field(:email, nulls: :last, rename: ->(name) { "users.#{name}" })
        definition.field(:last_name, rename: ->(_) { "surname" })

        expect(definition.fields_hash).to eql(
          {
            "email" => { nulls: :last, rename: "users.email" },
            "last_name" => { rename: "surname" }
          }
        )
      end
    end
  end

  xdescribe "#fields" do
    it "whitelists a list of sort fields with the same default options" do
      definition.fields(:first_name, :last_name, nulls: :last)
      definition.fields(:phone, nulls: :first)
      definition.fields(:email)

      expect(definition.fields_hash).to eql(
        {
          "email" => {},
          "first_name" => { nulls: :last },
          "last_name" => { nulls: :last },
          "phone" => { nulls: :first }
        }
      )
    end

    it "returns the same Field instance" do
      expect(definition.fields(:name)).to eql(definition)
    end

    context "with String :rename option value" do
      it "raises an error" do
        expect { definition.fields(:first_name, :last_name, rename: "surname") }.to raise_error
      end
    end

    context "with Proc :rename option value" do
      it "sets the :rename value to the transformed :name" do
        definition.fields(:first_name, :last_name, nulls: :last, rename: ->(name) { "users.#{name}" })
        definition.fields(:phone, nulls: :first)
        definition.fields(:email)

        expect(definition.fields_hash).to eql(
          {
            "email" => {},
            "first_name" => { nulls: :last, rename: "users.first_name" },
            "last_name" => { nulls: :last, rename: "users.last_name" },
            "phone" => { nulls: :first }
          }
        )
      end
    end
  end

  xdescribe "#field_defaults" do
    it "returns the field's configured default options" do
      definition.field(:email, nulls: :first, rename: "eadd")
      definition.field(:last_name)

      expect(definition.field_defaults("email")).to eql(nulls: :first, rename: "eadd")
      expect(definition.field_defaults("last_name")).to eql({})
    end
  end
end

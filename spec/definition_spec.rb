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

  describe "#field" do
    it "whitelists a filter field and sets its configuration" do
      definition.field(:email, some_option: "someval1")
      definition.field(:first_name, some_option: "someval2")
      definition.field(:last_name)

      expect(definition.fields_hash).to eql(
        {
          "email" => { some_option: "someval1" },
          "first_name" => { some_option: "someval2" },
          "last_name" => {}
        }
      )
    end

    it "ignores blank field name" do
      definition.field("")
      definition.field(nil)

      expect(definition.fields_hash).to be_empty
    end

    it "returns the Definition instance" do
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
        definition.field(:email, rename: ->(name) { "users.#{name}" })
        definition.field(:last_name, rename: ->(_) { "surname" })

        expect(definition.fields_hash).to eql(
          {
            "email" => { rename: "users.email" },
            "last_name" => { rename: "surname" }
          }
        )
      end
    end
  end

  describe "#fields" do
    it "whitelists a list of sort fields with the same default options" do
      definition.fields(:first_name, :last_name, some_option: "someval1")
      definition.fields(:phone, some_option: "someval2")
      definition.fields(:email)

      expect(definition.fields_hash).to eql(
        {
          "email" => {},
          "first_name" => { some_option: "someval1" },
          "last_name" => { some_option: "someval1" },
          "phone" => { some_option: "someval2" }
        }
      )
    end

    it "returns the same Definition instance" do
      expect(definition.fields(:name)).to eql(definition)
    end

    context "with String :rename option value" do
      it "raises an error" do
        expect { definition.fields(:first_name, :last_name, rename: "surname") }.to raise_error
      end
    end

    context "with Proc :rename option value" do
      it "sets the :rename value to the transformed :name" do
        definition.fields(:first_name, :last_name, some_option: "someval1", rename: ->(name) { "users.#{name}" })
        definition.fields(:phone, some_option: "someval2")
        definition.fields(:email)

        expect(definition.fields_hash).to eql(
          {
            "email" => {},
            "first_name" => { some_option: "someval1", rename: "users.first_name" },
            "last_name" => { some_option: "someval1", rename: "users.last_name" },
            "phone" => { some_option: "someval2" }
          }
        )
      end
    end
  end

  describe "#field_options" do
    it "returns the field's configured options" do
      definition.field(:email, nulls: :first, rename: "eadd")
      definition.field(:last_name)

      expect(definition.field_options("email")).to eql(nulls: :first, rename: "eadd")
      expect(definition.field_options("last_name")).to eql({})
    end
  end
end

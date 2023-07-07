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
            "email" => { type: :string },
            "first_name" => { some_option: "someval", type: :string },
            "last_name" => { some_option: "someval", type: :string }
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
          "email" => { some_option: "someval1", type: :string },
          "first_name" => { some_option: "someval2", type: :string },
          "last_name" => { type: :string }
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
            "last_name" => { rename: "surname", type: :string }
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
            "email" => { rename: "users.email", type: :string },
            "last_name" => { rename: "surname", type: :string }
          }
        )
      end
    end

    context "with blank :type option value" do
      it "defaults the field's type to :string" do
        definition.field(:email)

        expect(definition.fields_hash["email"]).to eql(type: :string)
      end
    end

    context "with invalid :type option value" do
      it "raises an error" do
        expect { definition.field(:email, type: :text) }.to raise_error(FilterParam::UnknownType)
      end
    end

    context "with valid :type option value" do
      it "sets the field type" do
        definition.field(:email, type: :string)
                  .field(:age, type: :numeric)
                  .field(:birth_date, type: :date)
                  .field(:created_at, type: :datetime)
                  .field(:active, type: :boolean)

        expect(definition.fields_hash).to eql(
          {
            "email" => { type: :string },
            "age" => { type: :numeric },
            "birth_date" => { type: :date },
            "created_at" => { type: :datetime },
            "active" => { type: :boolean }
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
          "email" => { type: :string },
          "first_name" => { some_option: "someval1", type: :string },
          "last_name" => { some_option: "someval1", type: :string },
          "phone" => { some_option: "someval2", type: :string }
        }
      )
    end

    it "returns the same Definition instance" do
      expect(definition.fields(:name)).to eql(definition)
    end

    context "with String :rename option value" do
      it "raises an error" do
        expect { definition.fields(:first_name, :last_name, rename: "surname") }.to raise_error(ArgumentError)
      end
    end

    context "with Proc :rename option value" do
      it "sets the :rename value to the transformed :name" do
        definition.fields(:first_name, :last_name, some_option: "someval1", rename: ->(name) { "users.#{name}" })
        definition.fields(:phone, some_option: "someval2")
        definition.fields(:email)

        expect(definition.fields_hash).to eql(
          {
            "email" => { type: :string },
            "first_name" => { some_option: "someval1", rename: "users.first_name", type: :string },
            "last_name" => { some_option: "someval1", rename: "users.last_name", type: :string },
            "phone" => { some_option: "someval2", type: :string }
          }
        )
      end
    end
  end

  describe "#field_options" do
    it "returns the field's configured options" do
      definition.field(:email, rename: "eadd")
      definition.field(:age, type: :numeric)

      expect(definition.field_options("email")).to eql(rename: "eadd", type: :string)
      expect(definition.field_options("age")).to eql(type: :numeric)
    end
  end
end

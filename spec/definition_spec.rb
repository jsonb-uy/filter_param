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
                  .field(:age, type: :integer)
                  .field(:weight, type: :decimal)
                  .field(:birth_date, type: :date)
                  .field(:created_at, type: :datetime)
                  .field(:active, type: :boolean)

        expect(definition.fields_hash).to eql(
          {
            "email" => { type: :string },
            "age" => { type: :integer },
            "birth_date" => { type: :date },
            "created_at" => { type: :datetime },
            "weight" => { type: :decimal },
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
      definition.field(:age, type: :integer)

      expect(definition.field_options("email")).to eql(rename: "eadd", type: :string)
      expect(definition.field_options("age")).to eql(type: :integer)
    end
  end

  describe "#field_type" do
    it "defaults to :string if the field has no configured type" do
      definition.field(:email)

      expect(definition.field_type(:email)).to eql(:string)
    end

    it "returns the field's configured type" do
      definition.field(:email, type: :string)
      definition.field(:age, type: :integer)
      definition.field(:balance, type: :decimal)
      definition.field(:active, type: :boolean)
      definition.field(:birth_date, type: :date)
      definition.field(:member_since, type: :datetime)

      expect(definition.field_type(:email)).to eql(:string)
      expect(definition.field_type(:age)).to eql(:integer)
      expect(definition.field_type(:balance)).to eql(:decimal)
      expect(definition.field_type(:birth_date)).to eql(:date)
      expect(definition.field_type(:member_since)).to eql(:datetime)
    end
  end

  describe "#filter!" do
    subject(:definition) do
      definition = described_class.new
      definition.field(:first_name)
      definition.field(:email, type: :string)
      definition.field(:age, type: :integer)
      definition.field(:balance, type: :decimal)
      definition.field(:active, type: :boolean)
      definition.field(:birth_date, type: :date)
      definition.field(:member_since, type: :datetime)
    end

    def user_emails(expression)
      definition.filter!(User.all, expression).pluck(:email)
    end

    context "when field is string" do
      context "with :eq operation" do
        it "correctly filters the records" do
          expect(user_emails("email eq 'johnny.apple@email.com'")).to eql(%w[johnny.apple@email.com])
          expect(user_emails("first_name eq 'Jane'")).to eql(%w[jane.doe@email.com jane.c.smith@email.com])
        end
      end

      context "with :neq operation" do
        it "correctly filters the records" do
          emails = User.where.not(email: "johnny.apple@email.com").pluck(:email)
          expect(user_emails("email neq 'johnny.apple@email.com'")).to eql(emails)
        end
      end
    end
  end
end

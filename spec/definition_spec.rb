# frozen_string_literal: true

RSpec.describe FilterParam::Definition do
  subject(:definition) { described_class.new }

  describe "#define" do
    context "with fields defined" do
      before do
        definition.define do
          fields :first_name, :last_name, type: :string
          field :email
        end
      end

      it "whitelists the fields" do
        email_field = definition.find_field!("email")
        first_name = definition.find_field!("first_name")
        last_name = definition.find_field!("last_name")

        expect(definition.field_names).to match_array(%w[email first_name last_name])
        expect(email_field.type).to eq(:string)
        expect(first_name.type).to eq(:string)
        expect(last_name.type).to eq(:string)
      end
    end

    context "with no fields defined" do
      it "raises an error" do
        expect { definition.define }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#field" do
    it "whitelists a filter field" do
      definition.field(:age, type: :integer)

      expect(definition.field_names).to match_array(%w[age])
      expect(definition.find_field!("age").type).to eq(:integer)
    end

    it "ignores blank field name" do
      definition.field("")
      definition.field(nil)

      expect(definition.field_names).to be_empty
    end

    it "returns the Definition instance" do
      expect(definition.field(:name)).to eql(definition)
    end

    context "with String :rename option value" do
      it "sets the field :rename value" do
        definition.field(:last_name, rename: "surname")

        last_name_field = definition.find_field!("last_name")
        expect(last_name_field.rename).to eql("surname")
      end
    end

    context "with Proc :rename option value" do
      it "sets the :rename value to the transformed :name" do
        definition.field(:email, rename: ->(name) { "users.#{name}" })
        definition.field(:last_name, rename: ->(_) { "surname" })

        email_field = definition.find_field!("email")
        last_name_field = definition.find_field!("last_name")

        expect(email_field.rename).to eql("users.email")
        expect(last_name_field.rename).to eql("surname")
      end
    end

    context "with blank :type option value" do
      it "defaults the field's type to :string" do
        definition.field(:email)

        expect(definition.find_field!("email").type).to eql(:string)
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

        expect(definition.find_field!("email").type).to eql(:string)
        expect(definition.find_field!("age").type).to eql(:integer)
        expect(definition.find_field!("birth_date").type).to eql(:date)
        expect(definition.find_field!("created_at").type).to eql(:datetime)
        expect(definition.find_field!("weight").type).to eql(:decimal)
        expect(definition.find_field!("active").type).to eql(:boolean)
      end
    end
  end

  describe "#fields" do
    it "whitelists a list of fields with the same configuration" do
      definition.fields(:weight, :height, type: :decimal)
      definition.fields(:phone, :email, type: :string)

      expect(definition.find_field!("weight").type).to eql(:decimal)
      expect(definition.find_field!("height").type).to eql(:decimal)
      expect(definition.find_field!("phone").type).to eql(:string)
      expect(definition.find_field!("email").type).to eql(:string)
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
        definition.fields(:weight, :height, type: :decimal, rename: ->(name) { "dim.#{name}" })
        definition.fields(:phone, :email, type: :string)

        expect(definition.find_field!("weight").rename).to eql("dim.weight")
        expect(definition.find_field!("height").rename).to eql("dim.height")
        expect(definition.find_field!("phone").rename).to be_nil
        expect(definition.find_field!("email").rename).to be_nil
      end
    end
  end

  describe "#field_names" do
    it "returns the whitelisted field names" do
      definition.define do
        fields :first_name, :last_name
        field :age
        field :height
      end

      expect(definition.field_names).to match_array(%w[first_name last_name age height])
    end
  end

  describe "#find_field!" do
    context "when field name is whitelisted" do
      it "returns the field instance" do
        definition.define do
          field :age
        end

        expect(definition.find_field!(:age)).to be_a(FilterParam::Field)
        expect(definition.find_field!("age")).to be_a(FilterParam::Field)
      end
    end

    context "when field name is not whitelisted" do
      it "raises an UnknownField error" do
        definition.define do
          field :age
        end

        expect { definition.find_field!(:name) }.to raise_error(FilterParam::UnknownField)
      end
    end
  end

  xdescribe "#filter!" do
    subject(:definition) do
      definition = described_class.new
      definition.fields(:first_name, :last_name)
      definition.field(:email, type: :string)
      definition.field(:score, type: :integer)
      definition.field(:balance, type: :decimal)
      definition.field(:active, type: :boolean)
      definition.field(:birth_date, type: :date)
      definition.field(:member_since, type: :datetime)
    end

    def user_emails(expression)
      definition.filter!(User.all, expression).pluck(:email)
    end

    context "with Proc :value field option" do
      it "pre-processes the field value in the expression string" do
        definition.field(:score, type: :integer, value: ->(value) { value + 10 })

        scores = definition.filter!(User.all, "score eq 90 or score eq 160").pluck(:score)
        expect(scores).to eql([100, 170])
      end
    end

    context "with :eq operation" do
      it "allows :null value" do
        expect(user_emails("last_name eq null")).to eql(%w[paul@domain.com ringo@domain.com george@domain.com])
        expect(user_emails("score eq null")).to eql(%w[edmund@email.com])
        expect(user_emails("balance eq null")).to eql(%w[ringo@domain.com])

        null_status_emails = User.where(active: nil).pluck(:email)
        expect(user_emails("active eq null")).to eql(null_status_emails)
        expect(user_emails("birth_date eq null")).to eql(%w[paul@domain.com edmund@email.com])

        null_member_since_emails = User.where(member_since: nil).pluck(:email)
        expect(user_emails("member_since eq null")).to eql(null_member_since_emails)
      end

      it "allows :string value" do
        expect(user_emails("email eq 'johnny.apple@email.com'")).to eql(%w[johnny.apple@email.com])
        expect(user_emails("first_name eq 'Jane'")).to eql(%w[jane.doe@email.com jane.c.smith@email.com])
      end

      it "allows :integer value" do
        expect(user_emails("score eq 180")).to eql(%w[ringo@domain.com george@domain.com])
        expect(user_emails("score eq 170")).to eql(%w[paul@domain.com])
      end

      it "allows :decimal value" do
        expect(user_emails("balance eq -123921349440.03")).to eql(%w[john.doe@email.com])
        expect(user_emails("balance eq -1.12")).to eql(%w[jane.doe@email.com])
        expect(user_emails("balance eq 0.0045")).to eql(%w[jane.c.smith@email.com])
        expect(user_emails("balance eq 42.9")).to eql(%w[rory.gallagher@email.com paul@domain.com])
        expect(user_emails("balance eq 9000192.0012450")).to eql(%w[johnny.apple@email.com])
        expect(user_emails("balance eq 42.9000001")).to eql(%w[george@domain.com])
        expect(user_emails("balance eq 10000.00001")).to eql(%w[edmund@email.com])
      end

      it "allows :boolean value" do
        active_emails = User.where(active: true).pluck(:email)
        invactive_emails = User.where(active: false).pluck(:email)

        expect(user_emails("active eq true")).to eql(active_emails)
        expect(user_emails("active eq false")).to eql(invactive_emails)
      end

      it "allows :date value" do
        expect(user_emails("birth_date eq '1985-05-01'")).to eql(%w[john.doe@email.com])
        expect(user_emails("birth_date eq '1985-05-02'")).to eql(%w[jane.doe@email.com jane.c.smith@email.com])
        expect(user_emails("birth_date eq '1986-06-10'")).to eql(%w[rory.gallagher@email.com])
        expect(user_emails("birth_date eq '1987-06-10'")).to eql(%w[johnny.apple@email.com])
        expect(user_emails("birth_date eq '1985-07-10'")).to eql(%w[ringo@domain.com])
        expect(user_emails("birth_date eq '1989-01-12'")).to eql(%w[george@domain.com])
      end

      it "allows :datetime value" do
        expect(user_emails("member_since eq '2023-03-01T08:09:00+07:00'")).to eql(%w[john.doe@email.com paul@domain.com])
        expect(user_emails("member_since eq '2023-03-01T01:09:01.000Z'")).to eql(%w[jane.doe@email.com])
        expect(user_emails("member_since eq '2023-03-01T09:09:00+09:00'")).to eql(%w[jane.c.smith@email.com])
        expect(user_emails("member_since eq '2023-03-02T00:00:00.000Z'")).to eql(%w[rory.gallagher@email.com])
      end
    end

    context "with :neq operation" do
      it "allows :null value" do
        non_null_last_name_emails = User.where.not(last_name: nil).pluck(:email)
        expect(user_emails("last_name neq null")).to eql(non_null_last_name_emails)

        non_null_score_emails = User.where.not(score: nil).pluck(:email)
        expect(user_emails("score neq null")).to eql(non_null_score_emails)

        non_null_balance_emails = User.where.not(balance: nil).pluck(:email)
        expect(user_emails("balance neq null")).to eql(non_null_balance_emails)

        non_null_status_emails = User.where.not(active: nil).pluck(:email)
        expect(user_emails("active neq null")).to eql(non_null_status_emails)

        non_null_birth_date_emails = User.where.not(birth_date: nil).pluck(:email)
        expect(user_emails("birth_date neq null")).to eql(non_null_birth_date_emails)

        non_null_member_since_emails = User.where.not(member_since: nil).pluck(:email)
        expect(user_emails("member_since neq null")).to eql(non_null_member_since_emails)
      end

      it "allows :string value" do
        emails = User.where.not(email: "johnny.apple@email.com").pluck(:email)

        expect(user_emails("email neq 'johnny.apple@email.com'")).to eql(emails)
      end

      it "allows :integer value" do
        emails = User.where.not(score: 170).pluck(:email)

        expect(user_emails("score neq 170")).to eql(emails)
      end

      it "allows :decimal value" do
        emails = User.where.not(balance: "42.9").pluck(:email)

        expect(user_emails("balance neq 42.9")).to eql(emails)
      end

      it "allows :boolean value" do
        active_emails = User.where(active: true).pluck(:email)
        inactive_emails = User.where(active: false).pluck(:email)

        expect(user_emails("active neq false")).to eql(active_emails)
        expect(user_emails("active neq true")).to eql(inactive_emails)
      end

      it "allows :date value" do
        emails = User.where.not(birth_date: Date.parse("1985-05-02")).pluck(:email)

        expect(user_emails("birth_date neq '1985-05-02'")).to eql(emails)
      end

      it "allows :datetime value" do
        emails = User.where.not(member_since: DateTime.parse("2023-03-01T08:09:00+07:00")).pluck(:email)

        expect(user_emails("member_since neq '2023-03-01T08:09:00+07:00'")).to eql(emails)
      end
    end

    context "with :gt operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name gt null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active gt true") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "allows :string value" do
        emails = User.where("last_name > ?", "Doe").pluck(:email)

        expect(user_emails("last_name gt 'Doe'")).to eql(emails)
      end

      it "allows :integer value" do
        expect(user_emails("score gt 160")).to eql(%w[paul@domain.com ringo@domain.com george@domain.com])
      end

      it "allows :decimal value" do
        expect(user_emails("balance gt 42.90")).to eql(%w[johnny.apple@email.com george@domain.com edmund@email.com])
      end

      it "allows :date value" do
        emails = User.where("birth_date > ?", Date.parse("1985-05-02")).pluck(:email)

        expect(user_emails("birth_date gt '1985-05-02'")).to eql(emails)
      end

      it "allows :datetime value" do
        emails = User.where("member_since > ?", DateTime.parse("2023-03-01T08:09:00+07:00")).pluck(:email)

        expect(user_emails("member_since gt '2023-03-01T08:09:00+07:00'")).to eql(emails)
      end
    end

    context "with :ge operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name ge null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active ge true") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "allows :string value" do
        emails = User.where("last_name >= ?", "Doe").pluck(:email)

        expect(user_emails("last_name ge 'Doe'")).to eql(emails)
      end

      it "allows :integer value" do
        emails = User.where("score >= ?", 160).pluck(:email)

        expect(user_emails("score ge 160")).to eql(emails)
      end

      it "allows :decimal value" do
        emails = User.where("balance >= ?", 42.9).pluck(:email)

        expect(user_emails("balance ge 42.90")).to eql(emails)
      end

      it "allows :date value" do
        emails = User.where("birth_date >= ?", Date.parse("1985-05-02")).pluck(:email)

        expect(user_emails("birth_date ge '1985-05-02'")).to eql(emails)
      end

      it "allows :datetime value" do
        emails = User.where("member_since >= ?", DateTime.parse("2023-03-01T08:09:00+07:00")).pluck(:email)

        expect(user_emails("member_since ge '2023-03-01T08:09:00+07:00'")).to eql(emails)
      end
    end

    context "with :lt operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name lt null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active lt false") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "allows :string value" do
        emails = User.where("last_name < ?", "Doe").pluck(:email)

        expect(user_emails("last_name lt 'Doe'")).to eql(emails)
      end

      it "allows :integer value" do
        emails = User.where("score < ?", 160).pluck(:email)

        expect(user_emails("score lt 160")).to eql(emails)
      end

      it "allows :decimal value" do
        emails = User.where("balance < ?", 42.9).pluck(:email)

        expect(user_emails("balance lt 42.90")).to eql(emails)
      end

      it "allows :date value" do
        emails = User.where("birth_date < ?", Date.parse("1985-05-02")).pluck(:email)

        expect(user_emails("birth_date lt '1985-05-02'")).to eql(emails)
      end

      it "allows :datetime value" do
        emails = User.where("member_since < ?", DateTime.parse("2023-03-01T08:09:00+07:00")).pluck(:email)

        expect(user_emails("member_since lt '2023-03-01T08:09:00+07:00'")).to eql(emails)
      end
    end

    context "with :le operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name le null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active le false") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "allows :string value" do
        emails = User.where("last_name <= ?", "Doe").pluck(:email)

        expect(user_emails("last_name le 'Doe'")).to eql(emails)
      end

      it "allows :integer value" do
        emails = User.where("score <= ?", 160).pluck(:email)

        expect(user_emails("score le 160")).to eql(emails)
      end

      it "allows :decimal value" do
        emails = User.where("balance <= ?", 42.9).pluck(:email)

        expect(user_emails("balance le 42.90")).to eql(emails)
      end

      it "allows :date value" do
        emails = User.where("birth_date <= ?", Date.parse("1985-05-02")).pluck(:email)

        expect(user_emails("birth_date le '1985-05-02'")).to eql(emails)
      end

      it "allows :datetime value" do
        emails = User.where("member_since <= ?", DateTime.parse("2023-03-01T08:09:00+07:00")).pluck(:email)

        expect(user_emails("member_since le '2023-03-01T08:09:00+07:00'")).to eql(emails)
      end
    end

    context "with :sw operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name sw null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active sw false") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "does not allow :integer value" do
        expect { user_emails("score sw 160") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected integer/)
      end

      it "does not allow :decimal value" do
        expect { user_emails("balance sw 42.9") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected decimal/)
      end

      it "does not allow :date value" do
        expect { user_emails("birth_date sw '1985-05-02'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected date/)
      end

      it "does not allow :datetime value" do
        expect { user_emails("member_since sw '2023-03-01T08:09:00+07:00'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected datetime/)
      end

      it "allows :string value" do
        emails = User.where("email like ?", "john%").pluck(:email)

        expect(user_emails("email sw 'john'")).to eql(emails)
      end
    end

    context "with :ew operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name ew null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active ew true") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "does not allow :integer value" do
        expect { user_emails("score ew 160") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected integer/)
      end

      it "does not allow :decimal value" do
        expect { user_emails("balance ew 42.9") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected decimal/)
      end

      it "does not allow :date value" do
        expect { user_emails("birth_date ew '1985-05-02'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected date/)
      end

      it "does not allow :datetime value" do
        expect { user_emails("member_since ew '2023-03-01T08:09:00+07:00'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected datetime/)
      end

      it "allows :string value" do
        emails = User.where("email like ?", "%domain.com").pluck(:email)

        expect(user_emails("email ew 'domain.com'")).to eql(emails)
      end
    end

    context "with :co operation" do
      it "does not allow :null value" do
        expect { user_emails("last_name co null") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected null/)
      end

      it "does not allow :boolean value" do
        expect { user_emails("active co true") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected boolean/)
      end

      it "does not allow :integer value" do
        expect { user_emails("score co 160") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected integer/)
      end

      it "does not allow :decimal value" do
        expect { user_emails("balance co 42.9") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected decimal/)
      end

      it "does not allow :date value" do
        expect { user_emails("birth_date co '1985-05-02'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected date/)
      end

      it "does not allow :datetime value" do
        expect { user_emails("member_since co '2023-03-01T08:09:00+07:00'") }.to raise_error(FilterParam::InvalidLiteral, /Unexpected datetime/)
      end

      it "allows :string value" do
        emails = User.where("email like ?", "%doe%").pluck(:email)

        expect(user_emails("email co 'doe'")).to eql(emails)
      end
    end

    context "with :pr operation" do
      it "does not accept a literal value" do
        expect { user_emails("last_name pr 'a'") }.to raise_error(FilterParam::ParseError, /Unexpected token "'a'"/)
      end

      it "allows :string field" do
        expect(user_emails("last_name pr")).to eql(%w[john.doe@email.com jane.doe@email.com jane.c.smith@email.com rory.gallagher@email.com johnny.apple@email.com])
      end

      it "allows :boolean field" do
        emails = User.where("active is not null").pluck(:email)

        expect(user_emails("active pr")).to eql(emails)
      end

      it "allows :integer field" do
        emails = User.where("score is not null").pluck(:email)

        expect(user_emails("score pr")).to eql(emails)
      end

      it "allows :decimal field" do
        emails = User.where("balance is not null").pluck(:email)

        expect(user_emails("balance pr")).to eql(emails)
      end

      it "allows :date field" do
        emails = User.where("birth_date is not null").pluck(:email)

        expect(user_emails("birth_date pr")).to eql(emails)
      end

      it "allows :datetime field" do
        emails = User.where("member_since is not null").pluck(:email)

        expect(user_emails("member_since pr")).to eql(emails)
      end
    end

    context "with :not operation" do
      it "negates a field expression" do
        emails = User.where.not(last_name: nil).pluck(:email)
        expect(user_emails("not last_name eq null")).to eql(emails)

        emails = User.where.not(last_name: "Doe").pluck(:email)
        expect(user_emails("not last_name eq 'Doe'")).to eql(emails)

        emails = User.where(last_name: "Doe").pluck(:email)
        expect(user_emails("not last_name neq 'Doe'")).to eql(emails)

        emails = User.where.not("last_name > ?", "Doe").pluck(:email)
        expect(user_emails("not last_name gt 'Doe'")).to eql(emails)

        emails = User.where.not("last_name < ?", "Doe").pluck(:email)
        expect(user_emails("not last_name lt 'Doe'")).to eql(emails)

        emails = User.where.not("last_name <= ?", "Doe").pluck(:email)
        expect(user_emails("not last_name le 'Doe'")).to eql(emails)

        emails = User.where.not("last_name like ?", "Do%").pluck(:email)
        expect(user_emails("not last_name sw 'Do'")).to eql(emails)

        emails = User.where.not("last_name like ?", "%oe").pluck(:email)
        expect(user_emails("not last_name ew 'oe'")).to eql(emails)

        emails = User.where.not("last_name like ?", "%o%").pluck(:email)
        expect(user_emails("not last_name co 'o'")).to eql(emails)

        expect(user_emails("not last_name pr")).to eql(%w[paul@domain.com ringo@domain.com george@domain.com edmund@email.com])
      end

      it "negates a group expression" do
        expect(user_emails("not(last_name neq 'Doe' or score gt 100)")).to eql(%w[john.doe@email.com])
      end
    end

    it "supports :and operation" do
      expect(user_emails("email ew 'domain.com' and score ge 180")).to eql(%w[ringo@domain.com george@domain.com])
    end

    it "supports :or operation" do
      expect(user_emails("not last_name pr or last_name eq 'Apple'")).to eql(%w[johnny.apple@email.com paul@domain.com ringo@domain.com george@domain.com edmund@email.com])
    end
  end
end

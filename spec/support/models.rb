class User < ActiveRecord::Base
  scope :with_status, ->(status) { where(status: status) }

  def self.create_test_data
    User.delete_all
    User.create(email: "john.doe@email.com",
                first_name: "John",
                last_name: "Doe",
                active: true,
                score: 100,
                birth_date: "1985-05-01",
                member_since: "2023-03-01T08:09:00+07:00",
                balance: BigDecimal("-123921349440.03"))
    User.create(email: "jane.doe@email.com",
                first_name: "Jane",
                last_name: "Doe",
                active: false,
                score: 120,
                birth_date: "1985-05-02",
                member_since: "2023-03-01T08:09:01+07:00",
                balance: BigDecimal("-1.12"))
    User.create(email: "jane.c.smith@email.com",
                first_name: "Jane",
                last_name: "Smith",
                active: true,
                score: 140,
                birth_date: "1985-05-02",
                member_since: "2023-03-01T08:09:00+08:00",
                balance: BigDecimal("0.0045"))
    User.create(email: "rory.gallagher@email.com",
                first_name: "Rory",
                last_name: "Gallagher",
                score: 150,
                birth_date: "1986-06-10",
                member_since: "2023-03-02T00:00:00+00:00",
                balance: BigDecimal("42.90"))
    User.create(email: "johnny.apple@email.com",
                first_name: "Johnny",
                last_name: "Apple",
                score: 160,
                birth_date: "1987-06-10",
                balance: BigDecimal("9000192.001245"))
    User.create(email: "paul@domain.com",
                first_name: "Paul",
                last_name: nil,
                score: 170,
                member_since: "2023-02-28T18:09:00-07:00",
                balance: BigDecimal("42.9"))
    User.create(email: "ringo@domain.com",
                first_name: "Ringo",
                last_name: nil,
                score: 180,
                birth_date: "1985-07-10")
    User.create(email: "george@domain.com",
                first_name: "George",
                last_name: nil,
                score: 180,
                birth_date: "1989-01-12",
                balance: BigDecimal("42.9000001"))
    User.create(email: "edmund@email.com",
                first_name: "Edmund",
                last_name: "   ",
                balance: BigDecimal("10000.00001"))
  end
end
User.create_test_data

class User < ActiveRecord::Base
  def self.create_test_data
    User.delete_all
    User.create(email: "john.doe@email.com",
                first_name: "John",
                last_name: "Doe",
                active: true,
                score: 100,
                balance: BigDecimal("-123921349440.03"))
    User.create(email: "jane.doe@email.com",
                first_name: "Jane",
                last_name: "Doe",
                active: false,
                score: 120,
                balance: BigDecimal("-1.12"))
    User.create(email: "jane.c.smith@email.com",
                first_name: "Jane",
                last_name: "Smith",
                active: true,
                score: 140,
                balance: BigDecimal("0.0045"))
    User.create(email: "rory.gallagher@email.com",
                first_name: "Rory",
                last_name: "Gallagher",
                score: 150,
                balance: BigDecimal("42.90"))
    User.create(email: "johnny.apple@email.com",
                first_name: "Johnny",
                last_name: "Apple",
                score: 160,
                balance: BigDecimal("9000192.001245"))
    User.create(email: "paul@domain.com",
                first_name: "Paul",
                last_name: nil,
                score: 170,
                balance: BigDecimal("42.9"))
    User.create(email: "ringo@domain.com",
                first_name: "Ringo",
                last_name: nil,
                score: 180)
    User.create(email: "george@domain.com",
                first_name: "George",
                last_name: nil,
                score: 180,
                balance: BigDecimal("42.9000001"))
    User.create(email: "excluded@email.com",
                first_name: "Excluded",
                last_name: "Record",
                balance: BigDecimal("10000.00001"))
  end
end
User.create_test_data

require "active_record"
require "pg"
require "sqlite3"
require "mysql2"

if ENV["DB_ADAPTER"] == "postgresql"
  ActiveRecord::Base.establish_connection(
    adapter: "postgresql",
    database: "filter_param",
    host: ENV.fetch("DB_HOST") { "localhost" },
    username: ENV.fetch("DB_USERNAME") { "postgres" },
    password: ENV.fetch("DB_PASSWORD") { "" },
    min_messages: "error"
  )
elsif ENV["DB_ADAPTER"] == "mysql2"
  ActiveRecord::Base.establish_connection(
    adapter: "mysql2",
    host: ENV.fetch("DB_HOST") { "localhost" },
    encoding: "utf8",
    reconnect: false,
    database: "filter_param",
    pool: 5,
    username: ENV.fetch("DB_USERNAME") { "root" },
    password: ENV.fetch("DB_PASSWORD") { "" },
    socket: "/tmp/mysql.sock"
  )
else
  ActiveRecord::Base.establish_connection(
    adapter: "sqlite3",
    database: ":memory:"
  )
end

module Schema
  def self.create
    ActiveRecord::Migration.verbose = false

    ActiveRecord::Schema.define do
      create_table :users, force: true do |t|
        t.string   :first_name, null: false
        t.string   :last_name
        t.string   :middle_name
        t.string   :email, null: false, index: { unique: true }
        t.string   :ssn, index: { unique: true }
        t.string   :mobile, index: { unique: true }
        t.datetime :member_since
        t.date     :birth_date
        t.boolean  :active
        t.float    :stats
        t.decimal  :balance, precision: 30, scale: 10
        t.bigint   :score
        t.timestamps null: false
      end
    end
  end
end

Schema.create

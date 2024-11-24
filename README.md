# FilterParam

[![Gem Version](https://badge.fury.io/rb/filter_param.svg)](https://badge.fury.io/rb/filter_param) [![CI](https://github.com/jsonb-uy/filter_param/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/jsonb-uy/filter_param/actions/workflows/ci.yml) [![codecov](https://codecov.io/gh/jsonb-uy/filter_param/graph/badge.svg?token=9242ULA2DC)](https://codecov.io/gh/jsonb-uy/filter_param) [![Maintainability](https://api.codeclimate.com/v1/badges/fb4df56368843000d1fd/maintainability)](https://codeclimate.com/github/jsonb-uy/filter_param/maintainability)

### Record Filtering for apps built on Rails/ActiveRecord 

Quickly implement record filtering in your APIs using a filter expression inspired by [SCIM Query](https://datatracker.ietf.org/doc/html/rfc7644#section-3.4.2.2):

```ruby
https://{some origin}/users?filter=first_name eq 'John' and last_name pr and 
  not (active eq false and (birth_date gt '1991-01-01' or birth_date eq null))
```

**TL;DR** See [ sample usage for Rails here ](#rails-usage). 

## Features

* Transpilation of the filter expression into SQL
* Whitelisting of allowed filter attributes
* Column name aliasing / expose a different attribute name in the API
* Pre-processing of filter values/literals
* Type validation of filter values (e.g., date and datetime literals should be in standard ISO 8601 format)
* Allows custom filter operators
* Expression grouping
* Supports **MySQL**, **PostgreSQL**, and **SQLite**
* Supports **Rails 6** and above

### Field Filter Operators
| Operator | Description | Example |
| ----------- | ----------- | ----------- |
| `eq` | Equal | name eq 'John' |
| `eq_ci` | Case-insensitive Equal | name eq_ci 'joHn' |
| `ne` | Not Equal | name ne 'john' |
| `co` | Contains | name co 'oh' |
| `sw ` | Starts With | name sw 'J' |
| `pr ` | Present (has value) | name pr |
| `gt` | Greater than | age gt 42 |
| `ge` | Greater than or equal to | price ge 19.80 |
| `lt` | Less than | created_at lt '2023-03-01T08:09:00+07:00' |
| `le` | Less than or equal to | birthdate le '1985-05-01' |

### Logical Operators
| Operator | Description |
| ----------- | ----------- |
| `and` | Logical "and" |
| `or` | Logical "or" |
| `not` | "Not" function |

### Grouping Operator
| Operator | Description |
| ----------- | ----------- |
| `()` | Precedence grouping |

### Literals
| Type | Filter Definition Symbol | Examples |
|-----------|----------- | ----------- |
| Boolean| `:boolean` | `true`, `false` |
| Integer| `:integer` | 40012, 100, 0, -51 |
| Decimal| `:decimal` | 4002.12, 0.05, -41.13 |
| String| `:string` | 'foo bar' |
| Date (ISO format) | `:date` | '2024-12-31' |
| Timestamp (ISO format) | `:datetime` | '2023-03-01T01:09:01.000Z', '2023-03-01T09:09:00+09:00' |
| Null | N/A | null |

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'filter_param'
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install filter_param
```

## Usage
### Basic

#### 1. Whitelist/define the filter fields

```ruby
fitler_param = FilterParam.define do
                 field :first_name, type: :string
                 field :last_name, rename: "family_name"
                 field :birth_date, type: :date
                 field :member_since, type: :datetime
                 field :active, type: :boolean
               end
```


This is is equivalent to:

```ruby
filter_param = FilterParam::Definition.new
                                      .field(:first_name, type: :string)
                                      .field(:last_name, rename: "family_name")
                                      .field(:birth_date, type: :date)
                                      .field(:member_since, type: :datetime)
                                      .field(:active, type: :boolean)
```

`field` method accepts the filter field name as the first argument. Any other configuration such as `:type` follows the name.

#### 2. Filter records using a filter expression

The `filter!` method accepts an `ActiveRecord_Relation` and the filter expression string from your API's request parameter. This method then transpiles the filter expression into SQL and returns a new `ActiveRecord_Relation` with the SQL conditions applied.

```ruby
rel = filter_param.filter!(User.all, "first_name eq 'John' and last_name pr and not (active eq false and (birth_date gt '1991-01-
01' or birth_date eq null))")
``` 

To see the SQL that will be executed in the ActiveRecord relation:

```ruby
rel.to_sql
=> "SELECT \"users\".* FROM \"users\" WHERE (first_name = 'John' AND 
    (family_name IS NOT NULL AND TRIM(family_name) != '') AND 
      NOT (active = 0 AND (birth_date > '1991-01-01' OR birth_date IS NULL)))"
```

### Errors

| Class | Description |
| ----------- | ----------- |
| `FilterParam::UnknownField` | A filter field in the given filter expression is not whitelisted in the filter definition. |
| `FilterParam::ParseError` | The given filter expression can't be parsed possibly due to malformed expression or syntax issue. |
| `FilterParam::InvalidLiteral` | A filter field value in the given filter expression is invalie (e.g., date and datetime should be in ISO 8601 format) |
| `FilterParam::ExpressionError` | Generic error caused by the given filter expression. |
| `FilterParam::UnknownType` | Configured `:type` of a filter field in the definition is invalid. |

## Development

1. If testing/developing for MySQL or PG, create the database first:<br/>

  ###### MySQL
  ```sh
  mysql> CREATE DATABASE filter_param;
  ```

  ###### PostgreSQL
  ```sh
  $ createdb filter_param
  ```

2. After checking out the repo, run `bin/setup` to install dependencies.
3. Run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. Use the environment variables below to target the database<br/><br/>
  
  By default, SQLite and the latest stable Rails version are used in tests and console. Refer to the environment variables below to change this:

  | Environment Variable | Values | Example |
  | ----------- | ----------- |----------- |
  | `DB_ADAPTER` | **Default: :sqlite**. `sqlite`,`mysql2`, or `postgresql` | ```DB_ADAPTER=postgresql bundle exec rspec```<br/><br/> ```DB_ADAPTER=postgresql ./bin/console``` |
  | `RAILS_VERSION` | **Default: 8-0** <br/><br/> `6-0`,`6-1`,`7-0`,`7-1`, `7-2`, `8-0` |```RAILS_VERSION=8-0 ./bin/setup```<br/><br/>```RAILS_VERSION=8-0 bundle exec rspec```<br/><br/> ```RAILS_VERSION=8-0 ./bin/console```|


<br/><br/>
To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsonb-uy/filter_param.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

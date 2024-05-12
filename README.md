# FilterParam

### Record Filtering for apps built on Rails/ActiveRecord 

Quickly implement record filtering in your APIs using a filter expression inspired by [SCIM Query](https://datatracker.ietf.org/doc/html/rfc7644#section-3.4.2.2):

```ruby
https://{some origin}/users?filter="first_name eq 'John' and last_name pr and
 not (active eq false or (birth_date < '1991-01-01' or birth_date eq null))" 
```

**TL;DR** See [ sample usage for Rails here ](#rails-usage). 

## Features

* Transpilation of the filter expression into SQL
* Whitelisting of allowed filter attributes
* Column name aliasing / expose a different attribute name in the API
* Pre-processing of filter values/literals
* Type validation of filter values (e.g., date and datetime literals should be in standard ISO 8601 format)
* Expression grouping
* Supports **MySQL**, **PostgreSQL**, and **SQLite**
* Supports **Rails 4.2** and above


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

#### 2. Transpile the filter expression from the parameter into SQL

The `filter!` method translates the filter expression string from your API's request parameter into an SQL:

```ruby
filter_param.filter!("")
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
  | `RAILS_VERSION` | **Default: 7-0** <br/><br/> `4-2`,`5-0`,`5-1`,`5-2`,`6-0`,`6-1`,`7-0` |```RAILS_VERSION=5-2 ./bin/setup```<br/><br/>```RAILS_VERSION=5-2 bundle exec rspec```<br/><br/> ```RAILS_VERSION=5-2 ./bin/console```|


<br/><br/>
To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jsonb-uy/rotulus.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

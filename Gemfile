# frozen_string_literal: true

source "https://rubygems.org"
gemspec

if ENV.fetch("COVERAGE", nil) == "true"
  gem "simplecov"
  gem "simplecov-cobertura"
end

gem "rake", "~> 13.0"
gem "rspec", "~> 3.0"
gem "rubocop", "~> 1.21"

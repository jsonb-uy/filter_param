# frozen_string_literal: true

source "https://rubygems.org"
gemspec

rails_version = ENV["RAILS_VERSION"] || "7-0"

gem "rake"
gem "rspec"
gem "rubocop"

if ENV.fetch("COVERAGE", nil) == "true"
  gem "simplecov"
  gem "simplecov-cobertura"
end

eval_gemfile("gemfiles/rails-#{rails_version}.gemfile")

git "https://github.com/rails/rails.git", branch: "#{rails_version}-stable" do
  gem "activerecord"
  gem "activesupport"
end

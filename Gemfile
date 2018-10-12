source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.1'

gem 'rails', '~> 5.2.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'jbuilder', '~> 2.5'
gem 'typhoeus'

# Image upload
gem 'carrierwave'
gem 'fog-aws'

# Auth
gem 'rack-cors'
gem 'bcrypt', '~> 3.1.7'
gem 'jwt'
gem 'simple_command'

# AWS S3
gem 'aws-sdk-s3', '~> 1'

# For scraping
gem 'headless'
gem 'phantomjs'
gem 'chromedriver-helper'
gem 'selenium-webdriver'
gem 'watir'

# job scheduling
gem 'sidekiq'
gem 'sidekiq-scheduler'
gem "puma_worker_killer"

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false

gem "dynamic_sitemaps"

gem 'net-ping'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'capybara', '~> 2.18'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end

group :development do
  gem 'foreman', '~> 0.84.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem "letter_opener"
end

group :test do
  gem 'shoulda'
  gem 'vcr'
end

group :staging, :production do
  gem 'heroku-deflater'
  gem 'rails_12factor'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

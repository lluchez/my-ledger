source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

ruby '2.2.6'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.6'
# Use Puma as the app server
gem 'puma', '3.11.2'
# Use SCSS for stylesheets
gem 'sass-rails', '5.0.7'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '4.1.6'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '4.2.2'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'bootstrap-sass'
gem 'devise'
# See documentation here: https://github.com/hisea/devise-bootstrap-views
gem 'devise-bootstrap-views'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'rollbar'
# gem 'oj', '~> 2.12.14' # Gen suggested by Rollbar for JSON serialization
gem "audited"

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Use mysql as the database for Active Record
  gem 'mysql2', '>= 0.3.18', '< 0.5'
  # To detect N+1 queries
  gem 'bullet'
  # Allow debugger
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
end

group :test do
  gem 'capybara'
  gem 'codecov', require: false
  # gem 'ci_reporter'
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  # gem "fakeredis"
  gem 'guard-rspec', require: false
  # gem 'launchy'
  # gem 'poltergeist'
  gem 'shoulda'
  gem 'simplecov', require: false
  gem 'rails-controller-testing'
  gem 'rspec-rails'
  gem 'rspec_junit_formatter'
  gem 'webmock'
end

group :development do
  gem 'listen'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console'
end

group :production do
  gem 'pg', '~> 0.21.0' # Heroku uses PostgreSQL
  gem 'rails_12factor'  #, '0.0.2'  # Heroku needs this gem to serve static assets such as images and CSS
end

gem 'rwr-view_helpers', '~> 0.1.1'
# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'wdm', '>= 0.1.0' if Gem.win_platform?

source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2'
gem 'haml', '~> 4.0'
gem 'pg'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
gem 'bootstrap-sass', '~> 3.2'
gem 'autoprefixer-rails', '~> 2.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails', '~> 5.0'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'   # disabled - this feature is unnecessary, but is causing interference
gem 'jquery-turbolinks', '~> 2.1'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 1.2'

gem "rufus-scheduler", '~> 3.0'
gem "dalli"
gem 'httparty', '~> 0.13'
gem 'htmlentities', '~> 4.3'

gem "tdameritrade_api",  :path=>'~/Development/gem-development/tdameritrade_api'
gem "stocktwits-api-ruby", "~> 0.0.1.1.alpha", :path=>'~/Development/gem-development/stocktwits-api-ruby'
gem "bindata"
gem 'ystock', '~> 0.4.10'

# Don't put these in the development-only group because certain
# financial data crawling functions make use of these gems.
gem 'nokogiri', '~>1.6'
gem 'capybara', '~>2.1'
gem 'poltergeist', '~>1.5'
gem 'http'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'pry', '~> 0.10'
  gem 'pry-rails', '~> 0.3'
#  gem 'linecache19', '>= 0.5.13', :git => 'https://github.com/robmathews/linecache19-0.5.13.git'
#  gem 'ruby-debug-base19x', '>= 0.11.30.pre10'
  #gem 'ruby-debug-ide', '~> 0.4.29'
  #   gem 'ruby-debug-base19x'
  # gem 'ruby-debug-ide'
end

# Use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]
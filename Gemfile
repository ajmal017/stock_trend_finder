ruby '2.3.1'
source 'https://rubygems.org'

### Rails and related ###
gem 'rails', '4.2.7'
gem 'pg',    '~> 0.18.1'
gem 'puma',  '~> 3.6'

gem 'dotenv-rails',   '~> 2.2', groups: [:development, :test] # Needs to be here so gems that use it will have access

gem 'autoprefixer-rails', '~> 2.1'
gem 'bootstrap-sass',     '~> 3.2'
gem 'coffee-rails',       '~> 4.0.0'
gem 'haml',               '~> 5.0'
gem 'jquery-rails'
gem 'jquery-turbolinks',  '~> 2.1'
gem 'jquery-ui-rails',    '~> 5.0'
gem 'sass-rails',         '~> 4.0.0'
gem 'turbolinks'
gem 'uglifier',           '>= 1.3.0'


### APIs for scraping/storing financial data ###
gem 'evernote_oauth',       '~> 0.2.3'
gem "stocktwits-api-ruby",  git: 'https://github.com/wakproductions/stocktwits-api-ruby.git'
gem "tdameritrade_api",     git: 'https://github.com/wakproductions/tdameritrade_api.git'
gem 'ystock',               '~> 0.4.10'

# Don't put these in the development-only group because certain
# financial data crawling functions make use of these gems.
gem 'capybara',     '~>2.1'
gem 'nokogiri',     '~>1.6'
gem 'poltergeist',  '~>1.5'

### All other gems ###

gem 'jbuilder', '~> 1.2'
gem 'json', '~> 1.8.2'

gem 'bindata',              '~> 2.1'  # Used for parsing data received by the TD Ameritrade API
gem 'httparty',             '~> 0.13'
gem 'htmlentities',         '~> 4.3'
gem 'rufus-scheduler',      '~> 3.0'
gem 'verbalize',            '~> 2.1'


group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

group :development, :test do
  gem 'clipboard',    '~> 1.1'

  gem 'pry',          '~> 0.10.4'
  gem 'pry-rails',    '~> 0.3.6'
  gem 'pry-byebug',   '~> 3.4.2'

  gem 'rspec-rails',  '~> 3.5'
end

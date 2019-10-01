class InstitutionalOwnershipSnapshot < ActiveRecord::Base
  belongs_to :ticker, primary_key: 'symbol', foreign_key: 'ticker_symbol'
end

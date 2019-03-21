class TickerChange < ActiveRecord::Base
  self.inheritance_column = :disable_single_table_inhertance

  enum type: {
    add: 'add',
    change_name: 'change_name',
    remove: 'remove',
    unscrape: 'unscrape',
    sp500_index: 'sp500_index',
  }
end

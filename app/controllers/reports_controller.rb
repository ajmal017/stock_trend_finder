require 'tdameritrade_data_interface/tdameritrade_data_interface'

module MyIncludedModule
  def self.included(klass)
    klass.extend ClassMethods
    puts "MyInCludedModules has been included in #{klass}"
  end

  module ClassMethods
    def test_method
      puts "test successful"
    end
  end
end

class ReportsController < ApplicationController

  def ema13_breaks

  end

  def hammers
    @report = run_query(TDAmeritradeDataInterface.select_hammers)
  end

  def active_stocks
    @report = run_query(TDAmeritradeDataInterface.select_active_stocks)
  end

private
  def run_query(qry)
    ActiveRecord::Base.connection.execute qry
  end
end

class StocktwitsController < ApplicationController
  layout "stocktwits"

  def index
    @twits = Stocktwit.showing.limit(20)
    ticker_list = Stocktwit.ticker_list('symbol')
    @ticker_list_symbol = ticker_list.to_a
    @ticker_list_count = @ticker_list_symbol.sort { |a,b| b['count'].to_i <=> a['count'].to_i }
    @ticker_list_updated = @ticker_list_symbol.sort { |a,b| b['last_updated_date'] <=> a['last_updated_date'] }
  end

  def load_twits
    @twits = Stocktwit.showing
    @twits = @twits.where("id < ?", params[:max]) if params[:max].present?
    @twits = @twits.where(symbol: params[:symbol]) if params[:symbol].present?
    @twits = @twits.limit(20)

    if @twits.length == 0
      render status: :ok, layout: false
    else
      render "load_twits", layout: false
    end
  end

  def refresh
    Stocktwit.sync_twits
    redirect_to stocktwits_path
  end

end

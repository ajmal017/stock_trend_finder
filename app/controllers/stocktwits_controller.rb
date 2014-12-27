class StocktwitsController < ApplicationController
  layout "stocktwits"
  before_action :user_id

  def index
    @twits = Stocktwit.showing(@user_id).limit(20)
    ticker_list = Stocktwit.ticker_list('symbol', @user_id)
    @ticker_list_symbol = ticker_list.to_a
    @ticker_list_count = @ticker_list_symbol.sort { |a,b| b['count'].to_i <=> a['count'].to_i }
    @ticker_list_updated = @ticker_list_symbol.sort { |a,b| b['last_updated_date'] <=> a['last_updated_date'] }
    @ticker_list_watching = Stocktwit.watching_list
  end

  def load_twits
    @twits = Stocktwit.showing(@user_id)
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

  def toggle_watching
    symbol = params[:symbol]
    @result = Stocktwit.toggle_watching(symbol)
    render status: :ok
  end

  def watching
    symbol = params[:symbol]
    @result = { watching: Stocktwit.watching?(symbol) }
    render json: @result
  end

private
  def user_id
    @user_id = params[:user_id] || 'greenspud'
  end
end
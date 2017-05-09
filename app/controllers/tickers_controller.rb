class TickersController < ApplicationController
  before_action :set_ticker, only: [:show, :edit, :update, :destroy]

  # GET /tickers
  # GET /tickers.json
  def index
    @tickers = Ticker.where(date_removed: nil).order(:symbol)
  end

  # GET /tickers/1
  # GET /tickers/1.json
  def show
  end

  # GET /tickers/new
  def new
    @ticker = Ticker.new
  end

  # GET /tickers/1/edit
  def edit
  end

  # POST /tickers
  # POST /tickers.json
  def create
    @ticker = Ticker.new(ticker_params)

    respond_to do |format|
      if @ticker.save
        format.html { redirect_to @ticker, notice: 'Ticker was successfully created.' }
        format.json { render action: 'show', status: :created, location: @ticker }
      else
        format.html { render action: 'new' }
        format.json { render json: @ticker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tickers/1
  # PATCH/PUT /tickers/1.json
  def update
    respond_to do |format|
      if @ticker.update(ticker_params)
        format.html { redirect_to @ticker, notice: 'Ticker was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @ticker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickers/1
  # DELETE /tickers/1.json
  def destroy
    @ticker.destroy
    respond_to do |format|
      format.html { redirect_to tickers_url }
      format.json { head :no_content }
    end
  end

  def note
    if params['note_text']
      Ticker.find_by(symbol: params['ticker']).create_note(params['note_text'], note_date: Date.today)
    end
    # TODO this have it flash a message
    render status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_ticker
      @ticker = Ticker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def ticker_params
      params.require(:ticker).permit(:symbol, :company_name, :scrape_data, :track_gap_up, :date_removed)
    end
end

class TweetsController < ApplicationController
  layout "stocktwits"
  before_action :set_tweet, only: [:show, :edit, :update, :destroy]

  # GET /tweets
  # GET /tweets.json
  def index
    @tweets = Tweet.all
  end

  # GET /tweets/1
  # GET /tweets/1.json
  def show
  end

  # GET /tweets/new
  def new
    @tweet = Tweet.new(message: converted_message, local_image_url: twit.image_cropped_url, stocktwit_id: twit.id)
  end

  # GET /tweets/1/edit
  # def edit
  # end

  # POST /tweets
  # POST /tweets.json
  def create
    @tweet = Tweet.new(tweet_params)
    if @tweet.valid?
      @tweet.twitter_message_id = Twitter::CreateTweet.call(tweet: @tweet).value
      @tweet.save!
      redirect_to @tweet, notice: 'Tweet was successfully created.'
    else
      render action: :new
    end
  end

  # PATCH/PUT /tweets/1
  # PATCH/PUT /tweets/1.json
  # def update
  #   respond_to do |format|
  #     if @tweet.update(tweet_params)
  #       format.html { redirect_to @tweet, notice: 'Tweet was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @tweet.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /tweets/1
  # DELETE /tweets/1.json
  # def destroy
  #   @tweet.destroy
  #   respond_to do |format|
  #     format.html { redirect_to tweets_url }
  #     format.json { head :no_content }
  #   end
  # end

  private
    def converted_message
      Twitter::ConvertMessage.call(message: twit.message).value
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_tweet
      @tweet = Tweet.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def tweet_params
      params.require(:tweet).permit(:message, :local_image_url, :stocktwit_id)
    end

    def twit
      @twit ||= Stocktwit.find(params[:stocktwit_id]) || OpenStruct.new()
    end
end

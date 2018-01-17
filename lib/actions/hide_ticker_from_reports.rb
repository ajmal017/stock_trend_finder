module Actions
  class HideTickerFromReports
    include MarketDataUtilities::DateTimeUtilities
    include Verbalize::Action

    input :ticker, optional: [:days]

    def call
      ticker.update!(hide_from_reports_until: calculated_visible_again_date)
      calculated_visible_again_date
    end

    private

    def calculated_visible_again_date
      @calculate_days ||=
        if @days.present?
          market_days_from(Date.current, @days)
        elsif current_days_hidden.nil?
          market_days_from(Date.current, 5)
        # elsif current_days_hidden <=3
        #   market_days_from(Date.current, 10)
        elsif current_days_hidden <= 11
          market_days_from(Date.current, 35)
        elsif current_days_hidden <= 40
          market_days_from(Date.current, 120)
        elsif current_days_hidden <= 122
          nil
        end
    end

    def current_days_hidden
      @current_days_hidden ||=
        if ticker.hide_from_reports_until.nil?
          nil
        else
          market_days_between(Date.today, ticker.hide_from_reports_until)
        end
    end

    def ticker
      @ticker_m ||= @ticker.is_a?(Ticker) ? @ticker : Ticker.find(@ticker)
    end

  end
end
module Strategies
  class SPXSwings
    include Verbalize::Action

    attr_reader   :mark,
                  :mark_date,
                  :swings,
                  :swing_start_value,
                  :swing_start_date,
                  :trend_direction, # -1 is down 1 is up
                  :threshold_value

    UP_THRESHOLD = 0.031
    DOWN_THRESHOLD = 0.085

    input :price_history

    # Assumption - price data starts on 1/1/1993
    def call
      @swings = [{swing_start_date: Date.new(1993,1,8), swing_start_value: 426.88, change_percent: nil}]
      @trend_direction = :up
      @swing_start_value = 426.88 # 1/8/93 bottom
      @swing_start_date = Date.new(1993,1,8) # 1/8/93 bottom
      @mark = price_history.first[:high]
      set_threshold(price_history.first)

      price_history.each do |ph|
        # binding.pry if ph[:timestamp].to_date == Date.new(2009,3,3) || $stop
        if @trend_direction == :up
          record_swing(ph) if ph[:low] < @threshold_value
        elsif @trend_direction == :down
          record_swing(ph) if ph[:high] > @threshold_value
        end

        set_threshold(ph)
      end

      swings
    end

    private

    def previous_swing
      @swings.last
    end

    def record_swing(last_candle)
      @swings << {
        swing_start_date: @mark_date,
        swing_start_value: @mark,
        change_percent: @mark / @swing_start_value - 1
      }

      if @trend_direction == :up
        @swing_start_value = @mark
        @swing_start_date = @mark_date
        @trend_direction = :down
        @mark = last_candle[:low]
        @mark_date = last_candle[:timestamp].to_date
      elsif @trend_direction == :down
        @swing_start_value = @mark
        @swing_start_date = @mark_date
        @trend_direction = :up
        @mark = last_candle[:high]
        @mark_date = last_candle[:timestamp].to_date
      end
    end


    def set_threshold(candle)
      @threshold_value =
        if @trend_direction == :up
          @mark = [mark, candle[:high]].max
          @mark_date = candle[:timestamp].to_date if @mark == candle[:high]
          [candle[:high], mark].max * (1-DOWN_THRESHOLD)
        elsif @trend_direction == :down
          @mark = [mark, candle[:low]].min
          @mark_date = candle[:timestamp].to_date if @mark == candle[:low]
          [candle[:low], mark].min * (1+UP_THRESHOLD)
        end
    end

  end
end
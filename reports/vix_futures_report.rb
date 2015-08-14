require 'market_data_utilities/vix_futures_date_utilities'

class VIXFuturesReport
  include VIXFuturesDateUtilities

  attr_reader :report_data

  def initialize
    @report_data = empty_report
  end

  # Inputs: id of a VIXFuturesHistory item.
  def build_report(vix_futures_history_id: nil)
    row = vix_futures_history_id.nil? ? VIXFuturesHistory.last : VIXFuturesHistory.find(vix_futures_history_id)
    @report = empty_report

    @report[:last_populated]     = row.snapshot_time
    @report[:days_to_expiration] = days_to_vix_expiration(from_date: row.snapshot_time.to_date)
    @report[:days_in_term]       = days_in_vix_futures_term(from_date: row.snapshot_time.to_date)

    @report[:vix] = row.VIX
    @report[:xiv] = row.XIV

    vx1,vx2 = row.futures_curve.take(2) # futures_curve is a hash in chronological order; this gets [[k1,v1],[k2,v2]]
    @report[:vx1] = vx1[1] # value of the nearest VIX future
    @report[:vx2] = vx2[1] # value of the nearest VIX future

    @report[:vx1_mix] = (@report[:days_to_expiration] + 1).to_f / @report[:days_in_term].to_f  # add 1 to include tradeable expiration day
    @report[:vx2_mix] = 1.to_f - @report[:vx1_mix]
    @report[:vx_avg]  = @report[:vx1_mix] * @report[:vx1] + @report[:vx2_mix] * @report[:vx2]

    @report[:roll_yield] = @report[:vx1].to_f / @report[:vix].to_f - 1
    @report[:contango]   = @report[:vx2].to_f / @report[:vx1].to_f - 1
    @report[:contango_roll] = @report[:vx2].to_f / @report[:vix].to_f - 1
    @report[:contango_1day_gain] = @report[:contango] / @report[:days_to_expiration].to_f
    @report[:contango_1day_gain_pts] = (@report[:contango_1day_gain] + 1) * @report[:xiv]

    @report[:vx1_delta] = (((@report[:vx1] + 1).to_f / @report[:vx1].to_f) - 1) * @report[:vx1_mix] * @report[:xiv]
    @report[:vx_avg_14] = 1 / (14.to_f / @report[:vx_avg]) * @report[:xiv]
    @report[:vx_avg_15] = 1 / (15.to_f / @report[:vx_avg]) * @report[:xiv]
    @report[:vx_avg_17] = 1 / (17.to_f / @report[:vx_avg]) * @report[:xiv]
    @report[:vx_avg_20] = 1 / (20.to_f / @report[:vx_avg]) * @report[:xiv]
    @report[:vx_avg_25] = 1 / (25.to_f / @report[:vx_avg]) * @report[:xiv]
    @report[:vx_avg_30] = 1 / (30.to_f / @report[:vx_avg]) * @report[:xiv]

    @report
  end

  private

  # This method is in place mainly to provide a specification for what's in the report
  def empty_report
    {
        last_populated: nil,        # Not yet populated
        days_to_expiration: nil,
        days_in_term: nil,
        # VIX and XIV market values
        vix: nil,
        xiv: nil,
        vx1: nil,
        vx2: nil,
        vx1_mix: nil,
        vx2_mix: nil,
        vx_avg: nil,

        # First 2 VIX futures, contango, and mix in XIV
        roll_yield: nil,
        contango: nil,
        contango_roll: nil,
        contango_1day_gain: nil,
        contango_1day_gain_pts: nil,

        # XIV sensitivity analysis
        vx1_delta: nil,   # 1 point move in the futures avg would move XIV X points
        vx_avg_14: nil,
        vx_avg_15: nil,
        vx_avg_17: nil,
        vx_avg_20: nil,
        vx_avg_25: nil,
        vx_avg_30: nil,
    }
  end
end
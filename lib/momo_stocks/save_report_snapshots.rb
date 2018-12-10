module MomoStocks
  class PostReportLineItems
    include MomoStocks::Common
    include Verbalize::Action

    LINE_ITEM_FIELD_FILTER=[
      :ticker_symbol,
      :last_trade,
      :change_percent,
      :gap_percent,
      :percent_above_52_week_high,
      :volume,
      :volume_average,
      :volume_ratio,
      :short_days_to_cover,
      :short_percent_of_float,
      :float,
      :float_percent_traded,
      :institutional_ownership_percent,
      :volume_average_premarket,
      :volume_ratio_premarket,
    ]

    input :built_at, :report_type, :line_items, :report_date

    def call
      send_report
    end

    private

    def report_hash
      @report_hash ||= {
        api_key: ENV['MOMO_STOCKS_API_KEY'],
        report_snapshot: {
          built_at: built_at,
          report_type: report_type,
          institutional_ownership_as_of: institutional_ownership_date,
          short_interest_as_of: short_interest_date,
          report_date: report_date,
          line_items: line_items.map { |li| li.slice(*LINE_ITEM_FIELD_FILTER) },
        }
      }
    end

    def send_report
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
      request.body = report_hash.to_json

      response = http.request(request)
    end

    def uri
      @uri ||= URI.parse(ENV['MOMO_STOCKS_API_POST_REPORT_URL'])
    end

  end
end
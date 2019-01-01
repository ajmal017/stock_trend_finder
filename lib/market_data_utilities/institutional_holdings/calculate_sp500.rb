module MarketDataUtilities
  module InstitutionalHoldings
    class CalculateSP500
      include Verbalize::Action

      input :date

      def call
        aggregated_values
      end

      private

      def aggregated_values
        av = institutional_ownership_snapshots.reduce({}) do |result, ios|
          result[:total_shares] = (result[:total_shares] || 0) + ios[:total_shares]
          result[:increased_positions_shares] = (result[:increased_positions_shares] || 0) + ios[:increased_positions_shares]
          result[:decreased_positions_shares] = (result[:decreased_positions_shares] || 0) + ios[:decreased_positions_shares]
          result[:held_positions_shares] = (result[:held_positions_shares] || 0) + ios[:held_positions_shares]
          result[:new_positions_shares] = (result[:new_positions_shares] || 0) + ios[:new_positions_shares]
          result[:sold_positions_shares] = (result[:sold_positions_shares] || 0) + ios[:sold_positions_shares]
          result[:latest_filing_date] = [result[:latest_filing_date], ios[:latest_filing_date]].compact.max

          result
        end

        av[:institutional_ownership_pct] =
          ((
            av[:increased_positions_shares].to_d -
            av[:decreased_positions_shares].to_d +
            av[:held_positions_shares].to_d +
            av[:new_positions_shares].to_d -
            av[:sold_positions_shares].to_d
          ) / av[:total_shares].to_d).round(3)

        av
      end

      def institutional_ownership_snapshots
        sp500_list.map do |symbol|
          InstitutionalOwnershipSnapshot
            .where(ticker_symbol: symbol)
            .where('scrape_date <= ? AND scrape_date > ?', date, date - 1.month)
            .order(scrape_date: :desc)
            .first
        end.compact
      end

      def sp500_list
        changed = TickerChange.sp500_index.where('action_date >= ?', date)
        added = changed.where(old_value: 'f', new_value: 't')
        removed = changed.where(old_value: 't', new_value: 'f')

        Ticker.where(sp500: true).pluck(:symbol) - added.pluck(:ticker_symbol) + removed.pluck(:ticker_symbol)
      end

    end
  end
end
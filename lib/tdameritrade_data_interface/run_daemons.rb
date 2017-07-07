module TDAmeritradeDataInterface
  module RunDaemons
    extend self

    def realtime_quote_daemon_block
      puts "Real Time Quote Import: #{Time.now}"
      if is_market_day? Date.today
        ActiveRecord::Base.connection_pool.with_connection do
          import_realtime_quotes
          puts "Copying from real time quotes cache to daily_stock_prices... #{Time.now}"
          copy_realtime_quotes_to_daily_stock_prices
        end

        puts "Posting reports to Momo Scans"
        MomoStocks::PostReport.(report_type: 'report_type_active')
        MomoStocks::PostReport.(report_type: 'report_type_gaps')
        MomoStocks::PostReport.(report_type: 'report_type_fifty_two_week_high')

        puts "Done #{Time.now}\n\n"
      else
        puts "Market closed today, no real time quote download necessary"
      end
    end

    def run_realtime_quotes_daemon
      schedulers = [
        '0,10,18,32,45,53 10-15 * * MON-FRI',
        '32,50 9 * * MON-FRI',
      ].map do |scheduled_time|
        scheduler = Rufus::Scheduler.new
        scheduler.cron(scheduled_time) { realtime_quote_daemon_block }
        scheduler
      end
      puts "#{Time.now} Beginning realtime quote import daemon..."
      schedulers
    end

    def run_daily_quotes_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('10 16 * * MON-FRI') do
        puts "Daily Quote Import: #{Time.now}"
        if is_market_day? Date.today
          ActiveRecord::Base.connection_pool.with_connection do
            update_daily_stock_prices_from_real_time_snapshot
          end
        else
          puts "Market closed today, no real time quote download necessary"
        end
      end
      puts "#{Time.now} Beginning daily quotes update daemon..."
      scheduler
    end

    def run_prepopulate_daily_stock_quotes_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('12 6 * * MON-FRI') do
        puts "Prepopulating daily_stock_quotes table: #{Time.now}"
        ActiveRecord::Base.connection_pool.with_connection do
          prepopulate_daily_stock_prices(Date.today)
        end
      end
      puts "#{Time.now} Beginning daily_stock_prices prepopulate daemon..."
      scheduler
    end

    def run_premarket_quotes_daemon
      schedulers = [
        '4,25,40,59 8 * * MON-FRI',
        '8,15,24 9 * * MON-FRI',
      ].map  do |scheduled_time|
        scheduler = Rufus::Scheduler.new
        scheduler.cron(scheduled_time) do
          puts "Premarket Quote Import: #{Time.now}"
          if is_market_day? Date.today
            ActiveRecord::Base.connection_pool.with_connection do
              import_premarket_quotes(date: Date.today)
            end
            puts "Posting reports to Momo Scans - #{Time.now}"
            MomoStocks::PostReport.(report_type: 'report_type_premarket')
            puts "Done"
          else
            puts "Market closed today, no real time quote download necessary"
          end
        end
        scheduler
      end
      puts "#{Time.now} Beginning premarket quotes update daemon..."
    end

    def run_premarket_memoization_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('0 5 * * MON-FRI') do
        puts "Memoizing premarket high, low, close, average volume - #{Time.now}"
        if is_market_day? Date.today
          ActiveRecord::Base.connection_pool.with_connection do
            populate_premarket_memoized_fields(Date.today)
          end
        else
          puts "Market closed today, no real time quote download necessary"
        end
      end
      puts "#{Time.now} Beginning premarket calculations memoization daemon..."
      scheduler
    end

    def run_afterhours_quotes_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('11,25,45,58 17,18,19,21 * * MON-FRI') do
        puts "Afterhours Quote Import: #{Time.now}"
        if is_market_day? Date.today
          ActiveRecord::Base.connection_pool.with_connection do
            import_afterhours_quotes(date: Date.today)
          end

          puts "Posting reports to Momo Scans - #{Time.now}"
          MomoStocks::PostReport.(report_type: 'report_type_after_hours')
          puts "Done"
        else
          puts "Market closed today, no real time quote download necessary"
        end
      end
      puts "#{Time.now} Beginning afterhours quotes update daemon..."
      scheduler
    end

    def run_stocktwits_sync_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('0 0,7,16 * * *') do
        puts "StockTwits data sync: #{Time.now}"
        ActiveRecord::Base.connection_pool.with_connection do
          Stocktwit.sync_twits
        end
      end
      puts "#{Time.now} Beginning StockTwits sync daemon..."
      scheduler
    end

    def run_import_vix_futures_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('0 9,10,14,17 * * MON-FRI') do
        puts "VIX Futures data sync: #{Time.now}"
        ActiveRecord::Base.connection_pool.with_connection do
          VIXFuturesHistory.import_vix_futures if is_market_day?(Date.today)
        end
        puts "Done"
      end
      puts "#{Time.now} Beginning VIX Futures History daemon..."
      scheduler
    end

    def run_db_maintenance_daemon
      scheduler = Rufus::Scheduler.new
      scheduler.cron('0 1 * * SAT') do
        puts "Running DB VACUUM: #{Time.now}"
        ActiveRecord::Base.connection_pool.with_connection do
          ActiveRecord::Base.connection.execute "VACUUM FULL"
          ActiveRecord::Base.connection.execute "VACUUM ANALYZE"
        end
        puts "Done"
      end

      scheduler_rts = Rufus::Scheduler.new
      scheduler_rts.cron('0 1 * * SAT') do
        puts "Resetting Realtime Snapshot Flags #{Time.now}"
        ActiveRecord::Base.connection_pool.with_connection do
          $stf.reset_snapshot_flags
        end
        puts "Done"
      end
      puts "#{Time.now} Beginning DB Maintenance daemon..."
      scheduler
    end

    # Not currently being used
    # def run_evernote_watchlist_daemon
    #   scheduler = Rufus::Scheduler.new
    #   scheduler.cron('45 1 * * *') do
    #     puts "Building Evernote Watchlist #{Time.now}"
    #     Evernote::EvernoteWatchList.build_evernote_watchlist
    #     puts "Done building Evernote Watchlist"
    #   end
    #   puts "#{Time.now} Beginning Evernote watchlist daemon..."
    #   scheduler
    # end

    def run_institutional_ownership_daemon
      scheduler = Rufus::Scheduler.new
      # See http://stackoverflow.com/questions/11683387/run-every-2nd-and-4th-saturday-of-the-month for explanation
      # of the Cron line
      # This is set to run the second and fourth Friday of the month at 7pm
      scheduler.cron('0 19 8-14,22-28 * *') do
        puts "#{Time.now} - Beginning download of institutional ownership..."
        if Date.today.wday == 5
          t = Time.now
          MarketDataUtilities::InstitutionalOwnership::ScrapeAll.call
          puts "Done (began at #{t}, now #{Time.now})"
        end
      end
      puts "#{Time.now} Beginning institutional ownership daemon..."

      scheduler
    end

    def run_short_interest_daemon
      scheduler = Rufus::Scheduler.new
      # This is set to run the 2nd, 13th, 17th,28th of every month
      scheduler.cron('0 19 2,13,17,28 * *') do
        puts "#{Time.now} - Beginning download of short interest..."
        t = Time.now
        MarketDataUtilities::ShortInterest::Update.call
      end
      puts "#{Time.now} Beginning short interest daemon..."

      scheduler
    end

  end
end
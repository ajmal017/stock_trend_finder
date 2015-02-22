namespace :stock_trend_finder do

  desc "Runs the daily market scanning background programs"
  task :run_daemons => :environment do
    $stf.run_realtime_quotes_daemon
    $stf.run_daily_quotes_daemon
    $stf.run_premarket_quotes_daemon
    $stf.run_prepopulate_daily_stock_quotes_daemon
    $stf.run_stocktwits_sync_daemon

    while 1 do
      # infinite loop until Ctrl+C hit
      sleep 200
    end
  end

end
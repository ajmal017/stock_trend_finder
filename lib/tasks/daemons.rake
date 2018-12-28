namespace :stock_trend_finder do

  desc "Runs the daily market scanning background programs"
  task :run_daemons => :environment do
    $stf.run_realtime_quotes_daemon
    $stf.run_daily_quotes_daemon
    $stf.run_premarket_quotes_daemon
    $stf.run_premarket_memoization_daemon
    $stf.run_afterhours_quotes_daemon
    $stf.run_prepopulate_daily_stock_quotes_daemon
    $stf.run_fundamentals_history_daemon
    $stf.run_report_snapshots_daemon
    $stf.run_db_maintenance_daemon
    $stf.run_institutional_ownership_daemon
    $stf.run_update_company_list_daemon
    # $stf.run_short_interest_daemon

    while 1 do
      # infinite loop until Ctrl+C hit
      sleep 200
    end
  end

end
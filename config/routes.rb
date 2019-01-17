StockTrendFinder::Application.routes.draw do
  resources :tweets
  resources :tickers
  resources :stocktwits, except: [:show]
  # Stocktwits AJAX calls
  post 'stocktwits/add_twit'        => 'stocktwits#add_twit'
  post 'stocktwits/edit_twit'       =>'stocktwits#edit_twit'
  post 'stocktwits/call_result'     => 'stocktwits#call_result'
  post 'stocktwits/hide'            => "stocktwits#hide"
  post 'stocktwits/load_twits'      => "stocktwits#load_twits"
  # post 'stocktwits/note'            => 'stocktwits#edit_note'
  get 'stocktwits/refresh'          => "stocktwits#refresh"
  get 'stocktwits/toggle_watching'  => "stocktwits#toggle_watching"
  get 'stocktwits/watching'         => "stocktwits#watching"

  get 'tdameritrade_token' => 'tdameritrade_refresh_token#show'
  put 'tdameritrade_token' => 'tdameritrade_refresh_token#update'

  namespace :reports do
    get 'active_stocks'
    get 'range'
    get 'premarket'
    get 'gaps'
    get 'afterhours'
    get 'earnings'
    get 'sma50_breaks'
    get 'sma200_breaks'
    get 'candle_row'
    get 'pctgainloss'
    get 'week52_highs'
    get 'week52_lows'
    get 'ticker_list'
    get 'ipo_list'
  end
  patch 'reports/hide/:symbol(.:format)', to: 'reports#hide_symbol', as: 'reports_hide_symbol'
  patch 'reports/unscrape/:symbol(.:format)', to: 'reports#unscrape_symbol', as: 'reports_unscrape_symbol'
  post 'tickers/:ticker/note', to: 'tickers#note', as: 'tickers_note'

  root 'home#index'
end

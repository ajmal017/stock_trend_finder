StockTrendFinder::Application.routes.draw do
  resources :tickers
  resources :stocktwits, except: [:show]
  # Stocktwits AJAX calls
  post 'stocktwits/add_twit'    => 'stocktwits#add_twit'
  post 'stocktwits/call_result' => 'stocktwits#call_result'
  post 'stocktwits/hide'        => "stocktwits#hide"
  post 'stocktwits/load_twits'  => "stocktwits#load_twits"
  post 'stocktwits/note'        => 'stocktwits#edit_note'
  get 'stocktwits/refresh'      => "stocktwits#refresh"
  get 'stocktwits/toggle_watching' => "stocktwits#toggle_watching"
  get 'stocktwits/watching'     => "stocktwits#watching"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

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
    get 'ticker_list'
    get 'ipo_list'
  end
  patch 'reports/hide/:symbol(.:format)', to: 'reports#hide_symbol', as: 'reports_hide_symbol'
  patch 'reports/unscrape/:symbol(.:format)', to: 'reports#unscrape_symbol', as: 'reports_unscrape_symbol'
  post 'tickers/:ticker/note', to: 'tickers#note', as: 'tickers_note'


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

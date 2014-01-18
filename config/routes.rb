NewSite::Application.routes.draw do
  get "feed_categories/index"

  get "feed_categories/new"

  get "feed_categories/edit"

  get "users/show"

  get "feeds/more"
  get "feeds/update_time"
  get "feeds/parse_feeds"
  get "feeds/subscriptions"
  get "feeds/find_twitter_id"
  get "feeds/set_display_setting"
  get "feeds/trending"
  get "feeds/saved"
  get "feeds/save"
  get "parse/parse_all_feeds"
  
  resources :feeds do
    get :subscribe, :unsubscribe, :destroy
  end
  
  resources :feed_contents do
    get :save, :redirect
  end
  
  resources :feed_categories do
    get :destroy
  end


  devise_for :users
  
  resources :landing

  root :to => "landing#index"
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
  
  devise_for :users, :path_names => {:sign_in => "login", :sign_out => "logout"}, :path => "d"
  resources :users
  
  namespace :admin do
    match '/' => 'users#index'
    resources :users
  end
end

CtfLab::Application.routes.draw do
  get "flag/destroy"
  # Root dir
  root :to => 'pages#home'

  # Devise
  devise_for :users, skip: [:sessions, :registrations]
  devise_scope :user do
    delete '/logout' => 'devise/sessions#destroy', :as => :logout
    get '/login' => 'devise/sessions#new', :as => :login
    post '/login' => 'devise/sessions#create'
    get '/register' => 'devise/registrations#new', :as => :registration
    post '/register' => 'devise/registrations#create'
  end
  
  # Challenges
  resources :challenge_groups, :path => 'challengeGroups'
  resources :challenges
  get '/challenges/:id/goto' => 'challenges#goto', :as => :challenge_goto
  get '/challenges/new/:group_id' => 'challenges#new', :as => :new_challenge_with_group
  get '/challenges/:id/show_hint/:challenge_hint_id' => 'challenges#show_hint', :as => :challenge_show_hint
  post '/challenges/:id/complete' => 'challenges#complete', :as => :challenge_complete
  get '/challenges/:id/complete' => 'challenges#complete'
  
  # Users
  get '/users/:id' => 'users#show', :as => :user
  get '/users/:id/admin_challenge_edit' => 'users#admin_challenge_edit', :as => :user_admin_challenge_edit

  # Flags
  delete '/flags/:id' => 'challenge_flags#destroy', as: :challenge_flag

  # User Messages
  resources :user_messages
  get '/user_messages/:id/reply' => 'user_messages#reply', :as => :reply_user_message
  
  # Leaderboards
  get '/leaderboard' => 'leaderboards#index', :as => :leaderboard
  get '/leaderboard/challenge/:challenge_id' => 'leaderboards#index', :as => :leaderboard_challenge
  get '/leaderboard/challenge_group/:challenge_group_id' => 'leaderboards#index', :as => :leaderboard_challenge_group

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
end


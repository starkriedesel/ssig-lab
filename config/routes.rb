CtfLab::Application.routes.draw do
  get "flag/destroy"
  # Root dir
  root :to => 'pages#home'

  # Devise
  devise_for :users, skip: [:sessions, :registrations]
  devise_scope :user do
    delete '/logout' => 'devise/sessions#destroy', as: :logout
    get '/login' => 'devise/sessions#new', as: :login
    post '/login' => 'devise/sessions#create'
    get '/register' => 'devise/registrations#new', as: :registration
    post '/register' => 'devise/registrations#create'
  end
  
  # Challenges
  resources :challenge_groups, :path => 'challengeGroups'
  resources :challenges
  get '/challenges/:id/launch' => 'challenges#launch', as: :challenge_launch
  get '/challenges/:id/giveup' => 'challenges#giveup', as: :challenge_giveup
  get '/challenges/new/:group_id' => 'challenges#new', as: :new_challenge_with_group
  get '/challenges/:id/show_hint/:challenge_hint_id' => 'challenges#show_hint', as: :challenge_show_hint
  post '/challenges/:id/complete' => 'challenges#complete', as: :challenge_complete
  get '/challenges/:id/complete' => 'challenges#complete'
  
  # Users
  get '/users/:id' => 'users#show', as: :user
  put '/users/:id/add_challenge' => 'users#add_challenge', as: :user_add_challenge
  delete '/users/:id/clear_challenge/:challenge_id' => 'users#clear_challenge', as: :user_clear_challenge

  # Flags
  delete '/flags/:id' => 'challenge_flags#destroy', as: :challenge_flag

  # User Messages
  resources :user_messages
  get '/user_messages/:id/reply' => 'user_messages#reply', as: :reply_user_message
  
  # Leaderboards
  get '/leaderboard' => 'leaderboards#index', as: :leaderboard
  get '/leaderboard/challenge/:challenge_id' => 'leaderboards#index', as: :leaderboard_challenge
  get '/leaderboard/challenge_group/:challenge_group_id' => 'leaderboards#index', as: :leaderboard_challenge_group
end


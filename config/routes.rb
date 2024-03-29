Rails.application.routes.draw do

  get 'neighborhoods/search'

  get 'geocode/search'
  get 'geocode/searchCityState'
  match 'search' => 'welcome#search', via: [:get, :post], as: :search
  get 'alerts/index'
  get 'alerts' => 'alerts#index', as: :alerts
  post 'alerts/create' => 'alerts#create', as: :alert_create

  resources :alerts
  resources :likes, only: :create
  get 'likes/data', to: 'likes#data'

  get 'alerts/new'

  get 'alerts/create'

  # get 'credits/index'

  # get 'credits/new'

  # get 'credits/create'
  # get 'credits/purchase'

  get 'test/test', to: 'test#test'

  authenticated :user do
    root :to => 'welcome#index', as: :authenticated_root
  end

  root :to => 'welcome#index'

  get 'interests', to: 'interests#index', as: :interests_index
  get 'interests/update', to: 'interests#index'
  resources :interests
  resources :background_jobs
  resources :people

  get 'profile/index'

  get 'profile/edit'
  get 'profile/password', as: :profile_change_password
  patch 'profile/update_password/:id' => 'profile#update_password', as: :profile_update_password

  get 'profile/notifications'
  get 'profile/messages'

  get 'profile/privacy' => 'profile#privacy', as: :profile_privacy
  get 'profile/notification_setting' => 'profile#notification_setting', as: :notification_settings
  patch 'profile/notification_setting' => 'profile#update_notification_setting', as: :notification_setting

  get 'profile/:id/followers' => 'profile#followers', as: :profile_followers

  get 'profile/:id/following' => 'profile#following', as: :profile_following

  get 'profile/:id' => 'profile#show', as: :profile
  get 'profile/:id' => 'profile#show', as: :user
  post 'profile/close', to: 'profile#close', as: :close_profile

  get 'profile/:id/activities_profile' => 'profile#activities_profile', as: :activities_profile
  get 'profile/:id/attending_profile' => 'profile#attending_profile', as: :attending_profile
  get 'profile/:id/followers_profile' => 'profile#followers_profile', as: :followers_profile
  get 'profile/:id/following_profile' => 'profile#following_profile', as: :following_profile
  get 'profile/:id/people_profile' => 'profile#people_profile', as: :people_profile

  patch 'profile/:id' => 'profile#update', as: :profile_update


  get 'welcome/index'
  get 'welcome/coming_soon'
  post 'welcome/invite_people' => 'welcome#invite_people', as: :twonoo_invite_people
  post 'welcome/trending' => 'welcome#trending', as: :trending

  get 'company/about' => 'company#about', as: :about
  get 'company/contact' => 'company#contact', as: :contact
  get 'company/terms' => 'company#terms', as: :terms
  get 'company/privacy' => 'company#privacy', as: :privacy
  post 'company/feedback' => 'company#feedback', as: :feedback

  get 'activities/index'
  get 'activities/user/:id' => 'activities#user', as: :user_activities
  get 'activities/attending/:id' => 'activities#attending', as: :attending_activities
  get 'activities/search'
  post 'activities/search' => 'activities#search', as: :activity_search
  get 'activities/show'
  get 'activities/new'
  post 'activities/new'
  get 'activities/edit'
  get 'activities/edit/:id' => 'activities#edit', as: :activity_edit
  get 'activities/cancel/:id' => 'activities#cancel', as: :activity_cancel
  get 'activities/copy/:id' => 'activities#copy', as: :activity_copy
  get 'activities/create'
  get 'activities/rsvp'
  get 'activities/unrsvp'

  post 'activities/invite_people/:id' => 'activities#invite_people', as: :invite_people
  post 'activities/comment' => 'activities#comment', as: :activity_comment
  get 'activities/add_to_gcal/:id' => 'activities#add_to_gcal', as: :google_calendar
  match '/auth/:provider/callback' => 'activities#add_to_gcal', via: [:get, :post], as: :google_cal_callback


  resources :activities
  # resources :credits

  devise_for :users, :controllers => {:omniauth_callbacks => 'users/omniauth_callbacks', :registrations => 'users/registrations'}

  resources :conversations, only: [:index, :show, :new, :create] do
    member do
      post :trash
      post :untrash
    end
  end
  get 'conversations/:id/display' => 'conversations#display_conversation', as: :display_conversation
  post 'conversations/show_messages/:id' => 'conversations#show_messages', as: :show_messages
  post 'conversations/load_earlier_messages/:id' => 'conversations#load_earlier_messages', as: :load_earlier_messages
  post 'conversations/reply/:id' => 'conversations#reply', as: :reply_conversation
  post 'conversations/send_message' => 'conversations#send_message', as: :send_message
  post 'conversations/new_messages' => 'conversations#new_messages', as: :new_messages

  get 'messages/display' => 'messages#display_messages', as: :display_messages
  get 'messages/number' => 'messages#num_messages', as: :num_messages

  get 'notifications/display' => 'notifications#display_notifications', as: :display_notifications
  get 'notifications/number' => 'notifications#num_notifications', as: :num_notifications
  get 'notifications/notifications_mobile' => 'notifications#notifications_mobile', as: :notifications_mobile

  get 'users/:id/following' => 'users#following', as: :following
  get 'users/:id/followers' => 'users#followers', as: :followers
  get 'users/follow/:id' => 'users#follow!', as: :follow
  get 'users/unfollow/:id' => 'users#unfollow!', as: :unfollow

  get 'activities/rsvp/:activity_id/:user_id' => 'activities#rsvp', as: :rsvp
  get 'activities/unrsvp/:activity_id/:user_id' => 'activities#unrsvp', as: :unrsvp


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

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

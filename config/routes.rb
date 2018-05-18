Rails.application.routes.draw do
  # ActiveAdmin
  constraints subdomain: 'admin' do
    devise_for :admin_users, ActiveAdmin::Devise.config.merge(:path => '')
    ActiveAdmin.routes(self)
    get '/admin-logout', to: 'static#admin_logout', as: :admin_logout
  end

  # Manager Pages
  constraints subdomain: 'www' do
    root to: 'static#main'
    get '/residents/login', to: 'residents#login'
    get '/communities/new', to: 'communities#new'
    get '/residents/password-reset', to: 'residents#password_reset'
    get '/residents/password-reset/:token', to: 'residents#password_new'
  end

  # API
  constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        post '/residents/token', to: 'residents#token'
        get '/residents/:id', to: 'residents#show'
        post '/residents/password-reset', to: 'residents#password_reset'
        post '/residents/password-reset/:token', to: 'residents#password_new'
        post '/communities', to: 'communities#create'
        get '/communities/:id/birthdays', to: 'communities#birthdays'
        get '/communities/:id/hosts', to: 'communities#hosts'
        get '/meals', to: 'meals#index'
        get '/meals/:meal_id', to: 'meals#show'
        get '/meals/:meal_id/prev', to: 'meals#show_prev'
        get '/meals/:meal_id/next', to: 'meals#show_next'
        post '/meals/:meal_id/residents/:resident_id', to: 'meals#create_meal_resident'
        delete '/meals/:meal_id/residents/:resident_id', to: 'meals#destroy_meal_resident'
        patch '/meals/:meal_id/residents/:resident_id', to: 'meals#update_meal_resident'
        post '/meals/:meal_id/residents/:resident_id/guests', to: 'meals#create_guest'
        delete '/meals/:meal_id/residents/:resident_id/guests/:guest_id', to: 'meals#destroy_guest'
        get '/meals/:meal_id/cooks', to: 'meals#show_cooks'
        patch '/meals/:meal_id/description', to: 'meals#update_description'
        patch '/meals/:meal_id/max', to: 'meals#update_max'
        patch '/meals/:meal_id/bills', to: 'meals#update_bills'
        patch '/meals/:meal_id/closed', to: 'meals#update_closed'
        get '/bills', to: 'bills#index'
        get '/bills/:id', to: 'bills#show'
        get '/rotations', to: 'rotations#index'
        get '/residents/:id/ical', to: 'residents#ical', as: :resident_ical
        get '/communities/:id/ical', to: 'communities#ical', as: :community_ical
        get '/version', to: 'site#version'
        get '/events/:id', to: 'events#show'
        get '/events', to: 'events#index'
        patch '/events/:id/update', to: 'events#update'
        delete '/events/:id/delete', to: 'events#destroy'
        post '/events', to: 'events#create'
        get '/guest-room-reservations/:id', to: 'guest_room_reservations#show'
        get '/guest-room-reservations', to: 'guest_room_reservations#index'
        patch '/guest-room-reservations/:id/update', to: 'guest_room_reservations#update'
        delete '/guest-room-reservations/:id/delete', to: 'guest_room_reservations#destroy'
        post '/guest-room-reservations', to: 'guest_room_reservations#create'
        get '/common-house-reservations/:id', to: 'common_house_reservations#show'
        get '/common-house-reservations', to: 'common_house_reservations#index'
        patch '/common-house-reservations/:id/update', to: 'common_house_reservations#update'
        delete '/common-house-reservations/:id/delete', to: 'common_house_reservations#destroy'
        post '/common-house-reservations', to: 'common_house_reservations#create'
      end
    end
  end

  # Root
  constraints subdomain: false do
    root to: 'static#root'
  end

  # Member Pages (swans.comeals.com, etc.)
  root to: 'static#root'
  get '/calendar/:type', to: 'residents#calendar'
  get '/guest-room', to: 'residents#guest_room'
  get '/meals/:id/edit', to: 'meals#edit', as: :meal
  get '/meals/:id/log', to: 'meals#log'
  get '/rotations/:id', to: 'rotations#show'
  get '/events/:id/edit', to: 'events#edit'
  get '/events/new', to: 'events#new'
  get '/common-house-reservations/:id/edit', to: 'common_house_reservations#edit'
  get '/common-house-reservations/new', to: 'common_house_reservations#new'
  get '/guest-room-reservations/:id/edit', to: 'guest_room_reservations#edit'
  get '/guest-room-reservations/new', to: 'guest_room_reservations#new'

  # Everything Else
  match '*path', to: 'application#not_found', via: :all
end

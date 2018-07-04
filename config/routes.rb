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
    get '/reset-password/(:token)', to: 'static#main'
    get '/create-community', to: 'static#main'
  end

  # API
  constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        post '/residents/token', to: 'residents#token'
        get '/residents/id', to: 'residents#show_id'
        get '/residents/name/:token', to: 'residents#show_name'
        post '/residents/password-reset', to: 'residents#password_reset'
        post '/residents/password-reset/:token', to: 'residents#password_new'
        post '/communities', to: 'communities#create'
        get '/communities/:id/birthdays', to: 'communities#birthdays'
        get '/communities/:id/hosts', to: 'communities#hosts'
        get '/communities/:id/calendar/:date', to: 'communities#calendar'
        get '/meals', to: 'meals#index'
        get '/meals/:meal_id', to: 'meals#show'
        get '/meals/:meal_id/history', to: 'meals#history'
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
        get '/rotations/:id', to: 'rotations#show'
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
  get '/calendar/(:type)/(:date)/(:modal)/(:view)/(:id)', to: 'residents#calendar'
  get '/meals/:id/edit/(history)', to: 'meals#edit', as: :meal

  # Everything Else
  match '*path', to: 'application#not_found', via: :all
end

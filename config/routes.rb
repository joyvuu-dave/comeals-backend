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
        get '/meals', to: 'meals#index'
        get '/meals/:meal_id', to: 'meals#show'
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
        get '/events', to: 'events#index'
      end
    end
  end

  # Root
  constraints subdomain: false do
    root to: 'static#root'
  end

  # Member Pages (swans.comeals.com, etc.)
  root to: 'static#root'
  get '/calendar', to: 'residents#calendar'
  get '/meals/:id/edit', to: 'meals#show', as: :meal
  get '/meals/:id/previous', to: 'meals#previous'
  get '/meals/:id/next', to: 'meals#next'
  get '/meals/:id/log', to: 'meals#log'
  get '/rotations/:id', to: 'rotations#show'
  get '/events/:id/edit', to: 'events#show'

  # Everything Else
  match '*path', to: 'application#not_found', via: :all
end

Rails.application.routes.draw do
  # ActiveAdmin
  constraints subdomain: 'admin' do
    devise_for :admin_users, ActiveAdmin::Devise.config.merge(:path => '')
    ActiveAdmin.routes(self)
  end

  # Manager Pages
  constraints subdomain: 'www' do
    root to: 'static#main'
    get '/managers/sign-up', to: 'managers#sign_up'
    get '/managers/login', to: 'managers#login'
    get '/residents/login', to: 'residents#login'
    get '/manager/:id', to: 'managers#show'
    get '/communities/new', to: 'communities#new'
    get '/communities/:id', to: 'communities#show'
    get '/managers/password-reset/:id', to: 'managers#password_reset'
    get '/residents/password-reset/:id', to: 'residents#password_reset'
  end

  # API
  constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        post '/managers', to: 'managers#create'
        get '/managers/communities', to: 'managers#communities'
        post '/managers/token', to: 'managers#token'
        post '/residents/token', to: 'residents#token'
        get '/residents/:id', to: 'residents#show'
        post '/communities', to: 'communities#create'
        get '/communities/:id', to: 'communities#show'
        get '/meals', to: 'meals#index'
        get '/meals/:meal_id', to: 'meals#show'
        get '/meals/:meal_id/attendees', to: 'meals#show_attendees'
        post '/meals/:meal_id/residents/:resident_id', to: 'meals#create_resident'
        delete '/meals/:meal_id/residents/:resident_id', to: 'meals#destroy_resident'
        patch '/meals/:meal_id/residents/:resident_id', to: 'meals#update_resident'
        post '/meals/:meal_id/residents/:resident_id/guests', to: 'meals#create_guest'
        delete '/meals/:meal_id/residents/:resident_id/guests', to: 'meals#destroy_guest'
        get '/meals/:meal_id/cooks', to: 'meals#show_cooks'
        patch '/meals/:meal_id', to: 'meals#update_meal_and_bills'
        patch '/meals/:meal_id/closed', to: 'meals#update_closed'
        patch '/meals/:meal_id/max', to: 'meals#update_max'
        get '/bills', to: 'bills#index'
        get '/bills/:id', to: 'bills#show'
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
  get '/meals/:id/edit', to: 'meals#show'
  get '/meals/:id/log', to: 'meals#log'
  get '/bills/:id', to: 'residents#bill'
  get '/residents/:id', to: 'residents#resident'
  get '/units/:id', to: 'residents#unit'
  get '/report', to: 'residents#report'

  # Everything Else
  match '*path', to: 'application#not_found', via: :all
end

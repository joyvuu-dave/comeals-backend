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
        get '/bills', to: 'bills#index'
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
  get '/meals/:id', to: 'residents#meal'
  get '/bills/:id', to: 'residents#bill'
  get '/residents/:id', to: 'residents#resident'
  get '/units/:id', to: 'residents#unit'
  get '/report', to: 'residents#report'

  # Everything Else
  match '*path', to: 'application#not_found', via: :all
end

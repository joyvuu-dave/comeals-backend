Rails.application.routes.draw do
  # Root
  root to: 'static#index'

  # ActiveAdmin
  constraints subdomain: 'admin' do
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
  end

  # Manager Pages
  constraints subdomain: 'www' do
    get '/sign-up', to: 'managers#sign_up'
    get '/login', to: 'managers#login'
    get '/manager/:id', to: 'managers#show'
    get '/community/:id', to: 'managers#community'
    get '/password-reset/:id', to: 'managers#password_reset'
  end

  # API
  constraints subdomain: 'api' do
    namespace :api do
      namespace :v1 do
        get '/residents/:id', to: 'residents#show'
        get '/communities/:id', to: 'communities#show'
      end
    end
  end

  # Member Pages (swans.comeals.com, etc.)
  get '/login', to: 'members#login'
  get '/calendar', to: 'members#calendar'
  get '/meals/:id', to: 'members#meal'
  get '/bills/:id', to: 'members#bill'
  get '/residents/:id', to: 'members#resident'
  get '/units/:id', to: 'members#unit'
  get '/report', to: 'members#report'
  get '/password-reset/:id', to: 'members#password_reset'
end

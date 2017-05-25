Rails.application.routes.draw do
  # ActiveAdmin
  constraints subdomain: 'admin' do
    devise_for :admin_users, ActiveAdmin::Devise.config
    ActiveAdmin.routes(self)
    match '*path', to: redirect('/login'), via: :all
  end

  # Manager Pages
  constraints subdomain: 'www' do
    root to: 'static#root_www'
    get '/sign-up', to: 'managers#sign_up'
    get '/login', to: 'managers#login'
    get '/manager/:id', to: 'managers#show'
    get '/communities/new', to: 'communities#new'
    get '/communities/:id', to: 'communities#show'
    get '/password-reset/:id', to: 'managers#password_reset'
    match '*path', to: redirect('/'), via: :all
  end

  # API
  constraints subdomain: 'api' do
    root to: 'static#root_api'
    namespace :api do
      namespace :v1 do
        post '/managers', to: 'managers#create'
        get '/managers/communities', to: 'managers#communities'
        post '/managers/token', to: 'managers#token'
        get '/residents/:id', to: 'residents#show'
        post '/communities', to: 'communities#create'
        get '/communities/:id', to: 'communities#show'
      end
    end
    match '*path', to: redirect('/'), via: :all
  end

  # Root
  constraints subdomain: false do
    root to: 'static#blank'
    match '*path', to: redirect('/'), via: :all
  end

  # Member Pages (swans.comeals.com, etc.)
  root to: 'static#root_member'
  get '/login', to: 'members#login'
  get '/calendar', to: 'members#calendar'
  get '/meals/:id', to: 'members#meal'
  get '/bills/:id', to: 'members#bill'
  get '/residents/:id', to: 'members#resident'
  get '/units/:id', to: 'members#unit'
  get '/report', to: 'members#report'
  get '/password-reset/:id', to: 'members#password_reset'
  match '*path', to: redirect('/'), via: :all
end

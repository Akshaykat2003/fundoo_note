Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      post 'register', to: 'users#register'
      post 'login', to: 'users#login'
      post 'forgot_password', to: 'users#forgot_password'
      post 'reset_password/:id', to: 'users#reset_password'
      get 'profile', to: 'users#profile'
    end
  end
end

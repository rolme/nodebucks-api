Rails.application.routes.draw do
  match '(*any)', to: redirect(subdomain: ''), via: :all, constraints: {subdomain: 'www'}

  scope :api, defaults: { format: :json } do
    resources :announcements, only: [:create] do
      get :last, on: :collection
    end
    resources :contacts, only: [:index, :create] do
      patch :reviewed
    end
    resources :cryptos, only: [:index, :show, :update], param: :slug do
      patch :delist
      patch :relist
      get :prices
      get :purchasable_statuses, on: :collection
      get :test_reward_scraper
    end
    resources :masternodes, only: [:index, :show], param: :slug
    resources :nodes, except: [:edit, :new], param: :slug do
      get :sell_prices
      post :generate, on: :collection
      patch :disburse
      patch :online
      patch :offline
      patch :purchase
      patch :reserve # Reserve sell price
      patch :restore
      patch :sell
      patch :undisburse
    end
    resources :orders, only: [:index, :show], param: :slug do
      patch :paid
      patch :unpaid
      patch :canceled
    end
    resources :rewards, only: [:index]
    resources :system, only: [:index] do
      patch :setting, on: :collection
    end
    resources :transactions, only: [:index, :update], param: :slug do
      patch :undo
      patch :processed
    end
    resources :users, except: [:edit, :new], param: :slug do
      patch :approved
      get :balance, on: :collection
      get :confirm
      patch :denied
      patch :enable
      patch :enable_2fa
      patch :disable
      patch :disable_2fa
      post :impersonate, on: :member
      post :password_confirmation
      patch :profile
      get :referrer, on: :collection
      patch :reset, on: :collection
      patch :reset_password
      post :secret_2fa, on: :collection
      post :verification_image
      get :verify
      patch :verify_id_image
      patch :update_affiliates
      patch :remove_affiliates
    end
    resources :withdrawals, only: [:create, :index, :show, :update], param: :slug do
      patch :confirm, on: :collection
    end
  end

  get '/counts', to: 'application#counts', defaults: { format: :json }
  post 'auth/login', to: 'users#login'
  post 'auth/admin', to: 'users#admin_login'
  post 'auth/oauth', to: 'users#callback'

  # get '/contact', to: 'home#contact'
  # get '/dashboard', to: 'home#dashboard'
  # get '/disclaimer', to: 'home#disclaimer'
  # get '/faq', to: 'home#faq'
  # get '/forgot_password', to: 'home#forgot_password'
  # get '/login', to: 'home#login'
  # get '/masternodes/:slug', to: 'home#masternodes'
  # get '/masternodes', to: 'home#masternodes'
  # get '/privacy', to: 'home#privacy'
  # get '/sign-up', to: 'home#sign_up'
  # get '/sitemap.xml', to: 'home#sitemap'
  # get '/terms', to: 'home#terms'
  # get '/what-are-masternodes', to: 'home#masternodes_description'

  get '*path', to: 'application#index'
end

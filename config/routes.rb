Chat::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "devise_overrides/registrations"
  }

  authenticate do
    resources :messages do
      collection { get :events }
    end
  end

  root to: 'home#index'

end

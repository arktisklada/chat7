Chat::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "devise_overrides/registrations"
  }

  resources :messages do
    collection { get :events }
  end

  root to: 'home#index'

end

Chat::Application.routes.draw do
  
  devise_for :users, :controllers => {
    :registrations => "devise_overrides/registrations"
  }

  # You can have the root of your site routed with "root"
  resources :messages do
    collection { get :events }
  end

  root to: 'home#index'

end

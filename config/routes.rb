Chat::Application.routes.draw do
  # You can have the root of your site routed with "root"
  root to: 'messages#index'
  resources :messages do
    collection { get :events }
  end

end

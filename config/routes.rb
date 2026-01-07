Rails.application.routes.draw do
  get "/cart", to: "carts#show", as: :cart
  post "/cart/:product_id/add", to: "carts#add_item", as: :add_item_to_cart
  delete "/cart/:product_id", to: "carts#remove_item", as: :remove_item_from_cart
  get "/cart/clear", to: "carts#clear", as: :clear_cart
  get "products/index"
  get "products/show"
  get "products/new"
  get "products/create"
  get "products/edit"
  get "products/update"
  get "products/destroy"
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
  resources :products
end

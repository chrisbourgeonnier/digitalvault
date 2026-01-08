Rails.application.routes.draw do
  # Devise authentication
  devise_for :users

  # Products (RESTful routes: index, show, new, create, edit, update, destroy)
  resources :products

  # Cart routes
  get "/cart", to: "carts#show", as: :cart
  post "/cart/:product_id/add", to: "carts#add_item", as: :add_item_to_cart
  delete "/cart/:product_id", to: "carts#remove_item", as: :remove_item_from_cart
  get "/cart/clear", to: "carts#clear", as: :clear_cart

  # Checkout routes
  post "/checkout", to: "checkout#create", as: :checkout
  get "/checkout/success", to: "checkout#success", as: :checkout_success
  get "/checkout/cancel", to: "checkout#cancel", as: :checkout_cancel

  # Secure download route
  get "/downloads/:id", to: "downloads#show", as: :download

  # Stripe webhook endpoint (POST only, CSRF protection skipped in controller)
  post "/webhooks/stripe", to: "webhooks#stripe"

  # Health check for load balancers
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path (optional - uncomment and set your root)
  # root "products#index"
end

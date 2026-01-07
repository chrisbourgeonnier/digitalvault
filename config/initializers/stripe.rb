# Configure Stripe with secret key from encrypted credentials
Stripe.api_key = Rails.application.credentials.dig(:stripe, :secret_key)

# Configure Stripe with secret key from encrypted credentials
# Only set the Stripe API key if the credential exists.
# This prevents errors during asset precompilation on deployment.
stripe_secret = Rails.application.credentials.dig(:stripe, :secret_key)
Stripe.api_key = stripe_secret if stripe_secret.present?

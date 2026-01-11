class WebhooksController < ApplicationController
  # Skip CSRF token verification for Stripe webhooks (we use Stripe signature instead)
  skip_before_action :verify_authenticity_token, only: [ :stripe ]

  def stripe
    # Get the raw request body for signature verification
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    endpoint_secret = Rails.application.credentials.dig(:stripe, :webhook_secret)

    # Verify the webhook signature
    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, endpoint_secret)
    rescue JSON::ParserError => e
      # Invalid payload
      render json: { error: "Invalid payload" }, status: 400 and return
    rescue Stripe::SignatureVerificationError => e
      # Invalid signature
      render json: { error: "Invalid signature" }, status: 400 and return
    end

    # Handle the event
    case event["type"]
    when "checkout.session.completed"
      handle_checkout_completed(event["data"]["object"])
    else
      Rails.logger.info "Unhandled webhook event type: #{event['type']}"
    end

    # Return success to Stripe
    render json: { status: "success" }, status: 200
  end

  private

  def handle_checkout_completed(session)
    # Find the order by Stripe session ID and mark it as paid
    order = Order.find_by(stripe_session_id: session["id"])

    if order
      order.update(status: "paid")
      Rails.logger.info "Order #{order.id} marked as paid"

      # Send order receipt email
      OrderMailer.with(order: order).receipt.deliver_later
      Rails.logger.info "Order receipt email queued for order #{order.id}"
    else
      Rails.logger.error "Order not found for session #{session['id']}"
    end
  end
end

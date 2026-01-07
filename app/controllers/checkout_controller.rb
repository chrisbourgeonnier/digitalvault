class CheckoutController < ApplicationController
  before_action :authenticate_user!

  def create
    # Build line items from cart for Stripe
    cart = session[:cart] || {}
    line_items = cart.keys.map do |product_id|
      product = Product.find_by(id: product_id)
      next unless product

      {
        price_data: {
          currency: "usd",
          product_data: { name: product.title },
          unit_amount: (product.price * 100).to_i  # Cents
        },
        quantity: cart[product_id.to_s]
      }
    end.compact

    # Create Stripe checkout session
    stripe_session = Stripe::Checkout::Session.create(
      payment_method_types: [ "card" ],
      line_items: line_items,
      mode: "payment",
      success_url: checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: checkout_cancel_url
    )

    # Create order record
    Order.create!(
      user: current_user,
      total: calculate_cart_total,
      cart_data: session[:cart],
      stripe_session_id: stripe_session.id,
      status: "pending"
    )

    redirect_to stripe_session.url, allow_other_host: true
  end

  def success
    session_id = params[:session_id]
    @order = Order.find_by(stripe_session_id: session_id)

    if @order
      session[:cart] = {}  # Clear cart
    else
      flash[:alert] = "Order not found"
      redirect_to cart_path
    end
  end

  def cancel
    flash[:notice] = "Checkout cancelled. Your cart is still saved."
    redirect_to cart_path
  end

  private

  def calculate_cart_total
    cart = session[:cart] || {}
    cart.keys.sum do |product_id|
      product = Product.find_by(id: product_id)
      product ? product.price * cart[product_id.to_s] : 0
    end
  end
end

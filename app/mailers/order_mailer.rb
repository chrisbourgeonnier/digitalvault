class OrderMailer < ApplicationMailer
  def receipt
    @order = params[:order]
    @user = @order.user
    @products = fetch_products_from_order

    mail(
      to: @user.email,
      subject: "Your DigitalVault Order ##{@order.id} - Download Your Files"
    )
  end

  private

  def fetch_products_from_order
    # Parse the cart_data JSON and fetch products
    cart_data = @order.cart_data.is_a?(String) ? JSON.parse(@order.cart_data) : @order.cart_data

    cart_data.keys.map do |product_id|
      Product.find_by(id: product_id)
    end.compact
  end
end

class DownloadsController < ApplicationController
  before_action :authenticate_user!

  def show
    product = Product.find(params[:id])

    # Check if user has purchased this product
    unless user_purchased?(product)
      redirect_to products_path, alert: "You must purchase this product before downloading."
      return
    end

    # Security: Use send_data to stream file without exposing direct URL
    if product.digital_file.attached?
      send_data product.digital_file.download,
                filename: product.digital_file.filename.to_s,
                type: product.digital_file.content_type,
                disposition: "attachment"
    else
      redirect_to products_path, alert: "File not found."
    end
  end

  private

  def user_purchased?(product)
    # Check if user has a paid order containing this product
    current_user.orders.where(status: "paid").each do |order|
      cart_data = order.cart_data
      return true if cart_data && cart_data.key?(product.id.to_s)
    end
    false
  end
end

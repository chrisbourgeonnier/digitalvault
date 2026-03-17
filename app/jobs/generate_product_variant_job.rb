class GenerateProductVariantJob < ApplicationJob
  queue_as :variants

  def perform(product_id)
    product = Product.find(product_id)
    return unless product.image.attached?

    product.image.variant(:thumb).processed
    Rails.logger.info "Generated variant for Product ##{product_id}"
  end
end

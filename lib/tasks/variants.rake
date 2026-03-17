# lib/tasks/variants.rake
namespace :variants do
  desc "Pre-generate image variants for all products"
  task generate: :environment do
    Product.transaction do
      Product.find_each(batch_size: 10) do |product|
        next unless product.image.attached?

        # Generate and save variant to R2
        product.image.variant(:thumb).processed

        puts "✅ Processed thumb for Product ##{product.id} (#{product.image.filename})"
      end
    end
    puts "🎉 All variants generated!"
  end
end

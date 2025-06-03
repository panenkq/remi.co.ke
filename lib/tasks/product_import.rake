require 'csv'

namespace :import do
  desc 'Import products from CSV'
  task products: :environment do
    filepath = 'lib/products.csv'

    unless File.exist?(filepath)
      puts "❌ File not found: #{filepath}"
      exit
    end

    shipping_category = Spree::ShippingCategory.first_or_create!(name: 'Default')

    CSV.foreach(filepath, headers: true) do |row|
      next if row['name'].nil? || row['name'].strip.empty?
      sku = row['sku']

      # Check if any variant with this SKU exists (including master variant)
      existing_variant = Spree::Variant.find_by(sku: sku)

      if existing_variant
        puts "⚠️ Skipping duplicate SKU: #{sku} (#{row['name']})"
        next
      end

      product = Spree::Product.new(
        name: row['name'],
        description: row['description'],
        price: row['price'],
        available_on: Time.current,
        shipping_category: shipping_category
      )

      # You must build the master variant with SKU
      product.master.sku = sku

      if product.save
        puts "✅ Created: #{product.name} (SKU: #{sku})"
      else
        puts "❌ Failed to create product #{row['name']}: #{product.errors.full_messages.join(', ')}"
      end
    end

    puts "🎉 All products processed!"
  end
end


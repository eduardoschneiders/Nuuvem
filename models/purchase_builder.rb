# TODO puts transactions
# TODO create in batches

class PurchaseBuilder
  def self.build(line_data)
    values = clear_values(line_data)
    
    purchaser_name    = values[0]
    item_description  = values[1]
    item_price        = values[2]
    purchase_count    = values[3]
    merchant_address  = values[4]
    merchant_name     = values[5]

    Purchase.new(
      purchaser: Purchaser.find_or_initialize_by(name: purchaser_name),
      items: [ Item.new(description: item_description, price: item_price) ],
      count: purchase_count,
      merchant: Merchant.find_or_initialize_by(name: merchant_name) do |m|
        m.address = merchant_address
      end
    )
  end

  private

  def self.clear_values(line_data)
    line_data.gsub("\n", "").gsub("\r", "").split("\t")
  end
end
require 'sinatra'
require 'pry'

current_dir = Dir.pwd
Dir["#{current_dir}/models/*.rb"].each { |file| require file }

get '/' do
  @merchants = {}
  erb :form
end


post '/receive_data' do
  file = params[:file][:tempfile]

  first_line = true
  @total_gross = 0

  @merchants = {}
  time = Time.now
  file.each_line do |line|
    if first_line
      first_line = false
      next
    end

    purchaser_name, item_description, item_price, purchase_count, merchant_address, merchant_name = line.gsub("\n", "").gsub("\r", "").split("\t")

    purchaser = create_purchaser(purchaser_name)
    merchant = create_merchant(merchant_name, merchant_address)
    purchase = create_purchase(purchaser, merchant, purchase_count)
    item = create_item(item_description, item_price, purchase)
    
    @total_gross += purchase.total_gross

    if @merchants[merchant.name]
      @merchants[merchant.name] += purchase.total_gross
    else
      @merchants[merchant.name] = purchase.total_gross
    end
  end

  Logger.new(STDOUT).info("Total Time taked: #{Time.now - time}")

  erb :form
end

private

def create_purchaser(name)
  Purchaser.find_or_create_by(name: name)
end

def create_merchant(name, address)
  Merchant.find_or_create_by(name: name) do |m|
    m.address = address
  end
end

def create_purchase(purchaser, merchant, count) 
  Purchase.create(purchaser: purchaser, merchant: merchant, count: count)
end

def create_item(description, price, purchase)
  Item.create(description: description, price: price, purchase: purchase)
end


# purchaser
#   name 

# itens
#   description
#   price

# purchase
#   count

# merchant
#   address
#   name
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
  purchases = []

  time = Time.now
  file.each_line do |line|
    if first_line
      first_line = false
      next
    end

    purchase = PurchaseBuilder.build(line)
    purchases.push(purchase)
  end

  Import.bulk_import(purchases)

  @merchants = Merchant.all.inject({}) do |h, merchant|
    h[merchant.name] =  merchant.purchases.inject(0) { |sum, p| sum += p.total_gross}
    h
  end


  Logger.new(STDOUT).info("Total Time taked: #{Time.now - time}")

  erb :form
end

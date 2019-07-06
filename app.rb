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

    purchase = PurchaseBuilder.build(line)
    purchase.save!
    
    @total_gross += purchase.total_gross

    if @merchants[purchase.merchant.name]
      @merchants[purchase.merchant.name] += purchase.total_gross
    else
      @merchants[purchase.merchant.name] = purchase.total_gross
    end
  end

  Logger.new(STDOUT).info("Total Time taked: #{Time.now - time}")

  erb :form
end

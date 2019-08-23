require File.expand_path '../../spec_helper.rb', __FILE__

describe "My Sinatra Application" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end


  it "should allow send data" do
    file = Rack::Test::UploadedFile.new(
      File.expand_path '../../fixtures/example.tab', __FILE__
    )

    post '/receive_data', { file: file }
    expect(last_response).to be_ok
    clear_response = last_response.body.gsub("\n", "").gsub("\s\s", "")
    binding.pry
    expect(clear_response).to include("<b>Bob's Pizza:</b> 20")
    expect(clear_response).to include("<b>Tom's Awesome Shop:</b> 50")
    expect(clear_response).to include("<b>Sneaker Store Emporium:</b> 25")
  end

  it 'should accept big file' do
    Logger.new(STDOUT).info("Build file")

    file = Rack::Test::UploadedFile.new(build_file(number_of_lines: 10_000))
    Logger.new(STDOUT).info("End build")

    post '/receive_data', { file: file }
    # expect(last_response).to be_ok
  end

  private 

  def build_file(number_of_lines: 1000)
    Tempfile.new.tap do |file|
      lines = number_of_lines.times.map do
        build_line
      end.join

      file.write(lines)
      file.rewind
    end
  end

  def build_line
    purchase = build(:purchase, :complete)
    [
      purchase.purchaser.name,
      purchase.items.first.description,
      purchase.items.first.price,
      purchase.count,
      purchase.merchant.address,
      purchase.merchant.name,
    ].join("\t") + "\n"
  end
end

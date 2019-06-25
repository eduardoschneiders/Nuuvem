require File.expand_path '../spec_helper.rb', __FILE__

describe "My Sinatra Application" do
  it "should allow accessing the home page" do
    get '/'
    expect(last_response).to be_ok
  end


  it "should allow send data" do
  	file = Rack::Test::UploadedFile.new(
  		File.expand_path '../fixtures/example.tab', __FILE__
  	)

    post '/receive_data', { file: file }
    expect(last_response).to be_ok
    clear_response = last_response.body.gsub("\n", "").gsub("\s\s", "")

    expect(clear_response).to include("<b>Bob's Pizza:</b> 20")
    expect(clear_response).to include("<b>Tom's Awesome Shop:</b> 50")
    expect(clear_response).to include("<b>Sneaker Store Emporium:</b> 25")
  end
end
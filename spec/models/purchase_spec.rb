require File.expand_path '../../spec_helper.rb', __FILE__

describe Purchase do
  let(:items) { [ double(price: 3) ] }

  before do
    allow_any_instance_of(Purchase).to receive(:items).and_return(items)
  end

  it 'should sum total gross' do
    p = Purchase.new(count: 4)
    expect(p.total_gross).to eq(12)
  end
end

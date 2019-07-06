require File.expand_path '../../spec_helper.rb', __FILE__
include Helper

describe Purchase do
  describe :total_gross do
    let(:purchase) do 
      create(:purchase,
        count: 4,
        items: 2.times.map { build(:item, price: 3) }
      )
    end

    it 'should sum total gross' do
      expect(purchase.total_gross).to eq(24)
    end
  end
end

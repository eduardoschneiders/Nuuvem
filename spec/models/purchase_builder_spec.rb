require File.expand_path '../../spec_helper.rb', __FILE__

describe PurchaseBuilder do
  describe :build do
    let(:line) { "Purchaser name 1\tDescription 1\t3\t4\tMerchant address 1\tMerchant name 1\n" }
    let(:purchase) { PurchaseBuilder.build(line) }

    it 'should be valid and enabled to save' do
      expect(purchase.valid?).to eql(true)
      expect { purchase.save!}.to change { purchase.new_record? }.from(true).to(false)
    end

    it 'should build purchase from raw line' do
      expect(purchase.purchaser.name).to eql("Purchaser name 1")
      expect(purchase.items.first.description).to eql("Description 1")
      expect(purchase.items.first.price).to eql(3)
      expect(purchase.count).to eql(4)
      expect(purchase.merchant.address).to eql("Merchant address 1")
      expect(purchase.merchant.name).to eql("Merchant name 1")
    end
  end
end

require File.expand_path '../spec_helper.rb', __FILE__

describe Import do
  describe '.generate_ids' do
    context "empty tables" do
      let(:objects) do
        [
          Item.new(description: "product one", price: 1),
          Item.new(description: "product two", price: 2),
          Item.new(description: "product three", price: 3)
        ]
      end


      it 'should has ids in ids array' do
        Import.send(:generate_ids, objects)
        expect(Import.class_variable_get(:@@ids)).to eql({})
      end
    end

    context "previous records on tables" do
      let(:objects) do
        [
          Item.new(description: "product one", price: 1),
          Item.new(description: "product two", price: 2),
          Item.new(description: "product three", price: 3)
        ]
      end


      it 'should has ids in ids array' do
        4.times.each do 
          Item.create(description: "description", price: 1)
        end

        Import.send(:generate_ids, objects)
        expect(Import.class_variable_get(:@@ids)).to eql({})
      end
    end

    context "complex objects" do
      let(:objects) do
        [
          Purchase.new(
            purchaser: Purchaser.new(name: 'Purchaser 1'),
            items: [
              Item.new(description: 'Product 1', price: 1),
              Item.new(description: 'Product 2', price: 2)
            ],
            count: 2,
            merchant: Merchant.new(name: 'Merchant 1', address: 'Address 1')
          ),
          Purchase.new(
            purchaser: Purchaser.new(name: 'Purchaser 2'),
            items: [
              Item.new(description: 'Product 1', price: 1),
              Item.new(description: 'Product 2', price: 2)
            ],
            count: 2,
            merchant: Merchant.new(name: 'Merchant 2', address: 'Address 2')
          )
        ]
      end

      it 'should has ids in ids array' do
        Import.send(:generate_ids, objects)
        expect(Import.class_variable_get(:@@ids)).to eql({
         "merchant_ids" => [1, 2],
         "purchaser_ids" => [1, 2],
         "purchase_ids" => [1, 2],
        })

        expect(Import.send(:next_id, Merchant)).to eql(3)
        expect(Import.send(:next_id, Purchase)).to eql(3)
        expect(Import.send(:next_id, Purchaser)).to eql(3)
      end
    end
  end

  let(:generate_sql) { Import.send(:generate_sql, objects) }

  context "simple objects" do
    let(:objects) do
      [
        Item.new(description: "product one", price: 1),
        Item.new(description: "product two", price: 2),
        Item.new(description: "product three", price: 3)
      ]
    end

    it "should insert items" do
      expect(generate_sql).to eq(
        "INSERT INTO items (description, price, purchase_id) VALUES ('product one', 1, NULL), ('product two', 2, NULL), ('product three', 3, NULL); "
      )

      expect { Import.bulk_import(objects) }.to change { Item.count }.from(0).to(3)
    end
  end

  context "complex objects" do
    let(:objects) do
      [
        Purchase.new(
          purchaser: Purchaser.new(name: 'Eduardo'),
          items: [
            Item.new(description: 'Product 1', price: 1),
            Item.new(description: 'Product 2', price: 2)
          ],
          count: 2,
          merchant: Merchant.new(name: 'Merchant', address: 'Address')
        )
      ]
    end

    it "should insert users and products" do
      expect(generate_sql).to eq(
        "INSERT INTO items (description, price, purchase_id) VALUES ('Product 1', 1, 1), ('Product 2', 2, 1); " +
        "INSERT INTO merchants (id, name, address) VALUES (1, 'Merchant', 'Address'); " +
        "INSERT INTO purchasers (id, name) VALUES (1, 'Eduardo'); " +
        "INSERT INTO purchases (id, count, merchant_id, purchaser_id) VALUES (1, 2, 1, 1); "
      )

      expect { Import.bulk_import(objects) }.to change { Item.count }.from(0).to(2)
        .and change { Merchant.count }.from(0).to(1)
        .and change { Purchaser.count }.from(0).to(1)
        .and change { Purchase.count }.from(0).to(1)
    end
  end

  context "complex objects" do
    let(:objects) do
      [
        Purchase.new(
          purchaser: Purchaser.new(name: 'Purchaser 1'),
          items: [
            Item.new(description: 'Product 1', price: 1),
            Item.new(description: 'Product 2', price: 2)
          ],
          count: 2,
          merchant: Merchant.new(name: 'Merchant 1', address: 'Address 1')
        ),
        Purchase.new(
          purchaser: Purchaser.new(name: 'Purchaser 2'),
          items: [
            Item.new(description: 'Product 3', price: 1),
            Item.new(description: 'Product 4', price: 2)
          ],
          count: 4,
          merchant: Merchant.new(name: 'Merchant 2', address: 'Address 2')
        )
      ]
    end

    it "should insert many users and products" do
      expect(generate_sql).to eq(
        "INSERT INTO items (description, price, purchase_id) VALUES " +
          "('Product 1', 1, 1), ('Product 2', 2, 1), " +
          "('Product 3', 1, 2), ('Product 4', 2, 2); " +
        "INSERT INTO merchants (id, name, address) VALUES " +
          "(1, 'Merchant 1', 'Address 1'), (2, 'Merchant 2', 'Address 2'); " +
        "INSERT INTO purchasers (id, name) VALUES " +
          "(1, 'Purchaser 1'), (2, 'Purchaser 2'); " +
        "INSERT INTO purchases (id, count, merchant_id, purchaser_id) VALUES " +
        "(1, 2, 1, 1), (2, 4, 2, 2); "
      )

      expect { Import.bulk_import(objects) }.to change { Item.count }.from(0).to(4)
        .and change { Merchant.count }.from(0).to(2)
        .and change { Purchaser.count }.from(0).to(2)
        .and change { Purchase.count }.from(0).to(2)
    end
  end
end
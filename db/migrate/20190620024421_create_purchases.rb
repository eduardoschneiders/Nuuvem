class CreatePurchases < ActiveRecord::Migration[5.2]
  def change
  	create_table :purchases do |t|
      t.integer :count, :default => 0
      t.references :merchant
      t.references :purchaser
    end
  end
end

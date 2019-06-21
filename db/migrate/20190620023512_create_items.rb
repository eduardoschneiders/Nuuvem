class CreateItems < ActiveRecord::Migration[5.2]
  def change
  	create_table :items do |t|
      t.string :description
      t.integer :price, :default => 0
      t.references :purchase
    end
  end
end

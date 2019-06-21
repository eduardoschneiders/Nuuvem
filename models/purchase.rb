class Purchase < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :purchaser

  has_many :items

  def total_gross
    items.inject(0) { |total, item| total += item.price * count }
  end
end
class Purchase < ActiveRecord::Base
  belongs_to :merchant
  belongs_to :purchaser

  has_many :items

  def total_gross
    items.sum(:price) * count 
  end
end
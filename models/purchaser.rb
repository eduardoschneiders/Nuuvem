class Purchaser < ActiveRecord::Base
	has_many :purchases
end
class Merchant < ActiveRecord::Base
	has_many :purchases
end
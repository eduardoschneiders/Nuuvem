FactoryBot.define do
  factory :purchaser do
  sequence :name do |n|
      "Purchaser name #{n}"
    end
  end

  trait :with_purchases do
    purchases { [build(:purchase)] }
  end
end

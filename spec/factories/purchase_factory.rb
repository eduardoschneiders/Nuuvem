FactoryBot.define do
  factory :purchase do
    count { 1 }
    items { [build(:item)] }

    trait :complete do
      purchaser { build(:purchaser) }
      merchant { build(:merchant) }
    end
  end
end

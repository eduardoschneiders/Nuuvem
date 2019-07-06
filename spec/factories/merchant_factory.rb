FactoryBot.define do
  factory :merchant do
    sequence :name do |n|
      "Merchant #{n}"
    end

    sequence :address do |n|
      "Merchant address #{n}"
    end
  end
end

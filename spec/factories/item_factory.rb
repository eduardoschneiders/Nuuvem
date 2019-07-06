FactoryBot.define do
  factory :item do
    sequence :description do |n|
      "Description #{n}"
    end

    price { 1 }
  end
end

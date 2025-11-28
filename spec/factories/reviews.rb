FactoryBot.define do
  factory :review do
    book { nil }
    user { nil }
    rating { 1 }
    body { "MyText" }
  end
end

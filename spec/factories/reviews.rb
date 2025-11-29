FactoryBot.define do
  factory :review do
    book { create(:book) }
    user { create(:user) }
    rating { 1 }
    body { "MyText" }
  end
end

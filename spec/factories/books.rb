FactoryBot.define do
  sequence :title do |n|
    "title_#{n}"
  end

  factory :book do
    title
  end
end

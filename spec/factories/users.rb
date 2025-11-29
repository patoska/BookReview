FactoryBot.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :user do
    email
    status { 0 }

    trait :banned do
      status { 1 }
    end
  end
end

FactoryGirl.define do
  factory :role do
    name ""
  end

  factory :guest do
    role
    id 0
    username ""
    email ""

    factory :user do
      id { generate(:random_integer) }
      username { "user#{id}" }
      email { "#{username}@example.com" }

      factory :admin do
        association :role, name: "admin"
      end
    end
  end
end

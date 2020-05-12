FactoryBot.define do
  factory :admin, parent: :user do
    is_admin { true }
  end
end
FactoryBot.define do
  factory :doctor, parent: :user do
    is_doctor { true }
  end
end
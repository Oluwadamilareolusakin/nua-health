FactoryBot.define do
  factory :patient, parent: :user do
    is_patient { true }
  end
end
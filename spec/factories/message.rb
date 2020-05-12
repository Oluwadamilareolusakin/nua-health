FactoryBot.define do
  factory :message do
    inbox
    outbox
    body { "Some fancy message in the factory" }
  end
end
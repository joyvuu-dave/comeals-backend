FactoryGirl.define do
  factory :unit do
    community
    name { ("A".."Z").to_a.sample }
  end
end

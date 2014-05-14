# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do |f|
    f.sequence :username do |n|
      "testuser#{n}"
    end
    f.firstname "Test"
    f.sequence :lastname do |n|
      "User #{n}"
    end
    f.sequence :email do |n|
      "testuser#{n}@ga.co"
    end
    f.password "password"
    f.password_confirmation "password"
  end
end

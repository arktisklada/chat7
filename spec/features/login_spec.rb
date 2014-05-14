require 'spec_helper'

# describe "Logging In" do
#   it "tests login" do

#     DatabaseCleaner.clean
#     user = FactoryGirl.create(:user)

#     visit "/users/sign_in"
#     fill_in :user_email, :with => user.email
#     fill_in :user_password, :with => "password"

#     click_button "login_submit"

#     expect(page).to have_content(user.username)
#   end
# end



describe "Logging In", :type => :feature do

  it "signs in with correct credentials" do
    DatabaseCleaner.clean
    @user = FactoryGirl.create(:user)
    visit '/users/sign_in'

    fill_in :user_email, :with => @user.email
    fill_in :user_password, :with => 'password'
    click_button :login_submit
    expect(page).to have_content @user.username
  end

  # given(:other_user) { User.make(:email => 'other@example.com', :password => 'rous') }

  # scenario "Signing in as another user" do
  #   visit '/sessions/new'
  #   within("#session") do
  #     fill_in 'Login', :with => other_user.email
  #     fill_in 'Password', :with => other_user.password
  #   end
  #   click_link 'Sign in'
  #   expect(page).to have_content 'Invalid email or password'
  # end
end
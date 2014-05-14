require 'spec_helper'
require 'benchmark'

describe "Messaging" do
  let(:user) { FactoryGirl.create(:user) }

  it "tests authorized page" do
    sign_in user.email, user.password

    visit "/messages"
    expect(page).to have_content('Members')
  end

  it "sends a message" do
    sign_in user.email, user.password

    message = "A little test"

    visit "/messages"
    fill_in :message_content, :with => message
    click_button "message_submit"
  end
end

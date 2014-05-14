require 'spec_helper'

describe User do
  before(:each) do
    @user_attr = FactoryGirl.attributes_for(:user)
    @user = FactoryGirl.build(:user)
  end

  it "should create a new instance of a user given valid attributes" do
    User.create!(@user_attr)
  end
end

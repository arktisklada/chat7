require 'spec_helper'

feature 'Visitor signs up' do
  scenario 'with valid email and password' do
    sign_up_with 'valid@example.com', 'password', 'valid', 'Valid', 'User'

    expect(page).to have_content('Welcome')
    DatabaseCleaner.clean
  end

  scenario 'with invalid email' do
    sign_up_with 'invalid_email', 'password', 'valid', 'Valid', 'User'

    expect(page).to have_content('Sign in')
  end

  scenario 'with blank password' do
    sign_up_with 'valid@example.com', '', 'valid', 'Valid', 'User'

    expect(page).to have_content('Sign in')
  end

  scenario 'with blank username' do
    sign_up_with 'valid@example.com', 'password', '', 'Valid', 'User'

    expect(page).to have_content('Sign in')
  end
end
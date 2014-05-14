module Features
  module SessionHelpers
    def sign_up_with(email, password, username, firstname, lastname)
      visit new_user_registration_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Username', with: username
      fill_in 'Firstname', with: firstname
      fill_in 'Lastname', with: lastname
      click_button 'Sign up'
    end

    def sign_in(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
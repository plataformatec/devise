# frozen_string_literal: true

require 'test_helper'

class DatabaseAuthenticationTest < Devise::IntegrationTest
  test 'sign in with email of different case should succeed when email is in the list of case insensitive keys' do
    create_user(email: 'Foo@Bar.com')

    sign_in_as_user do
      fill_in 'email', with: 'foo@bar.com'
    end

    assert warden.authenticated?(:user)
  end

  test 'sign in with email of different case should fail when email is NOT the list of case insensitive keys' do
    swap Devise, case_insensitive_keys: [] do
      create_user(email: 'Foo@Bar.com')

      sign_in_as_user do
        fill_in 'email', with: 'foo@bar.com'
      end

      refute warden.authenticated?(:user)
    end
  end

  test 'sign in with email including extra spaces should succeed when email is in the list of strip whitespace keys' do
    create_user(email: ' foo@bar.com ')

    sign_in_as_user do
      fill_in 'email', with: 'foo@bar.com'
    end

    assert warden.authenticated?(:user)
  end

  test 'sign in with email including extra spaces should fail when email is NOT the list of strip whitespace keys' do
    swap Devise, strip_whitespace_keys: [] do
      create_user(email: 'foo@bar.com')

      sign_in_as_user do
        fill_in 'email', with: ' foo@bar.com '
      end

      refute warden.authenticated?(:user)
    end
  end

  test 'sign in should not authenticate if not using proper authentication keys' do
    swap Devise, authentication_keys: [:username] do
      sign_in_as_user
      refute warden.authenticated?(:user)
    end
  end

  test 'sign in with invalid email should return to sign in form with error message' do
    store_translations :en, devise: { failure: { admin: { not_found_in_database: 'Invalid email address' } } } do
      sign_in_as_admin do
        fill_in 'email', with: 'wrongemail@test.com'
      end

      assert_contain 'Invalid email address'
      refute warden.authenticated?(:admin)
    end
  end

  test 'sign in with invalid pasword should return to sign in form with error message' do
    sign_in_as_admin do
      fill_in 'password', with: 'abcdef'
    end

    assert_contain 'Invalid Email or password'
    refute warden.authenticated?(:admin)
  end

  test 'when in paranoid mode and without a valid e-mail' do
    swap Devise, paranoid: true do
      store_translations :en, devise: { failure: { not_found_in_database: 'Not found in database' } } do
        sign_in_as_user do
          fill_in 'email', with: 'wrongemail@test.com'
        end
        
        assert_not_contain 'Not found in database'
        assert_contain 'Invalid Email or password.'
      end
    end
  end

  test 'error message is configurable by resource name' do
    store_translations :en, devise: { failure: { admin: { invalid: "Invalid credentials" } } } do
      sign_in_as_admin do
        fill_in 'password', with: 'abcdef'
      end

      assert_contain 'Invalid credentials'
    end
  end

  test 'valid sign in calls after_database_authentication callback' do
    user = create_user(email: ' foo@bar.com ')

    User.expects(:find_for_database_authentication).returns user
    user.expects :after_database_authentication

    sign_in_as_user do
      fill_in 'email', with: 'foo@bar.com'
    end
  end

  test 'sign in regenerates bcrypt password hash when stretches changes' do
    swap Devise, send_password_change_notification: true do
      password = '12345678'
      user = create_user(password: password)

      before_sign_in_password_hash = user.encrypted_password
      before_sign_in_password_cost = ::BCrypt::Password.new(before_sign_in_password_hash).cost

      user.class.stretches = before_sign_in_password_cost + 1

      assert_email_not_sent do
        visit new_user_session_path
        fill_in 'email', with: user.email
        fill_in 'password', with: password
        click_button 'Log in'
      end

      refute User.validations_performed

      after_sign_in_password_hash = user.reload.encrypted_password
      after_sign_in_password_cost = ::BCrypt::Password.new(after_sign_in_password_hash).cost

      assert_not_equal before_sign_in_password_hash, after_sign_in_password_hash
      assert_equal before_sign_in_password_cost + 1, after_sign_in_password_cost
    end
  end

  test 'sign in does not regenerate bcrypt password hash when stretches stay the same' do
    password = '12345678'
    user = create_user(password: password)

    before_sign_in_password_hash = user.encrypted_password

    visit new_user_session_path
    fill_in 'email', with: user.email
    fill_in 'password', with: password
    click_button 'Log in'

    after_sign_in_password_hash = user.reload.encrypted_password

    assert_equal before_sign_in_password_hash, after_sign_in_password_hash
  end
end

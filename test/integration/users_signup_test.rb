require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
	test "invalid signup information" do
		get signup_path
		assert_no_difference 'User.count',  1 do
			post users_path, params: { user: { name: "Example User",
				email: "user@example.com",
				password: "password",
				password_confirmation: "password" } }
		end
		follow_redirect!
		assert_template 'users/show'
		assert is_logged_in?
		#cmt: assert_not flash.FILL_IN
		#assert_select 'div#<CSS id for error explanation>'
		#assert_select 'div.<CSS class for field with error>'
	end
end

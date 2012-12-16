require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test "username, email, password, password_confirmation must not be empty" do
    user = User.new
    assert user.invalid?, "Empty User should be failure"
    assert user.errors[:username].any?, "Empty Username is a failure"
    assert user.errors[:email].any?, "Empty Email is a failure"
    assert user.errors[:password].any?, "Empty Password is a failure"
  end
  
  test "password must be at least 6 characters" do
    user = User.new
    
    user.password = "abc"
    user.invalid?
    assert user.errors[:password].any?, "Password validation failed (3 chars)"
    
    user.password = "abcd"
    user.invalid?
    assert user.errors[:password].any?, "Password validation failed (4 chars)"
    
    user.password = "abcde"
    user.invalid?
    assert user.errors[:password].any?, "Password validation failed (5 chars)"
    
    user.password = "abcdef"
    user.invalid?
    assert ! user.errors[:password].any?, "Password validation failed (6 chars), should be ok"
  end
  
  test "email must be valid" do
    user = User.new
    
    user.email = "xyz"
    user.invalid?
    assert user.errors[:email].any?, "Email must be valid (no @ or .)"
    
    user.email = "xyz@"
    user.invalid?
    assert user.errors[:email].any?, "Email must be valud (no .)"
    
    user.email = "@abc.def"
    user.invalid?
    assert user.errors[:email].any?, "Email must be valid (no chars before @)"
    
    user.email = "xyz@abc.def"
    user.invalid?
    assert ! user.errors[:email].any?, "Email must be valid, should be ok"
  end
end

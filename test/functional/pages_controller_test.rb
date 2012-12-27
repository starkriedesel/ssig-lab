require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get home" do
    get :home
    assert_response :success
  end

  test "no login navbar" do
    get :home
    assert_select '.navbar' do
      assert_select '.brand'
      assert_select '.active'
    end
  end
end

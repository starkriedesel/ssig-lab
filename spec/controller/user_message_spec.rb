require 'spec_helper'

describe UserMessagesController do
  extend ControllerMacros
  login_user

  it "should have an index action" do
    get 'index'
    response.should be_success
  end
end

require 'test_helper'

class NavbarCellTest < Cell::TestCase
  test "show" do
    invoke :show
    assert_select "div"
  end
  

end

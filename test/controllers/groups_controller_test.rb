require "test_helper"

class GroupsControllerTest < ActionDispatch::IntegrationTest
  test "home redirects to group calendar" do
    get root_path
    assert_redirected_to group_calendar_path(groups(:hexatombe).share_token)
  end

  test "show renders dashboard" do
    get group_calendar_path(groups(:hexatombe).share_token)
    assert_response :success
    assert_select "h1", groups(:hexatombe).name
  end

  test "show renders people list" do
    get group_calendar_path(groups(:hexatombe).share_token)
    assert_select ".person-row", count: 2
  end

  test "show renders calendar element" do
    get group_calendar_path(groups(:hexatombe).share_token)
    assert_select "#calendar"
  end

  test "show renders share URL" do
    get group_calendar_path(groups(:hexatombe).share_token)
    assert_select "input[readonly]"
  end

  test "show with invalid token returns not found" do
    get group_calendar_path("invalid_token")
    assert_response :not_found
  end
end

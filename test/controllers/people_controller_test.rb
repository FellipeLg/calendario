require "test_helper"

class PeopleControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = groups(:hexatombe).share_token
  end

  test "new renders form" do
    get new_group_person_path(@token)
    assert_response :success
    assert_select "h1", "Nova pessoa"
  end

  test "create adds person to group" do
    assert_difference "Person.count", 1 do
      post group_people_path(@token), params: {
        person: { name: "Dave", contact: "dave@test", color: "#a8323e" }
      }
    end
    assert_redirected_to group_calendar_path(@token)
    assert_equal "Dave", Person.last.name
  end

  test "create with invalid data re-renders form" do
    assert_no_difference "Person.count" do
      post group_people_path(@token), params: {
        person: { name: "", color: "" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form with person data" do
    person = people(:alice)
    get edit_group_person_path(@token, person)
    assert_response :success
    assert_select "h1", "Editar cadastro"
  end

  test "update modifies person" do
    person = people(:alice)
    patch group_person_path(@token, person), params: {
      person: { name: "Alice Updated" }
    }
    assert_redirected_to group_calendar_path(@token)
    assert_equal "Alice Updated", person.reload.name
  end

  test "destroy removes person" do
    person = people(:bob)
    assert_difference "Person.count", -1 do
      delete group_person_path(@token, person)
    end
    assert_redirected_to group_calendar_path(@token)
  end
end

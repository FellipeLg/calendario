require "test_helper"

class AvailabilitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = groups(:hexatombe).share_token
  end

  test "new renders form" do
    get new_group_availability_path(@token)
    assert_response :success
    assert_select "h1", "Nova disponibilidade"
  end

  test "new with date param pre-fills date" do
    get new_group_availability_path(@token, date: "2026-07-01")
    assert_response :success
  end

  test "create adds availability" do
    assert_difference "Availability.count", 1 do
      post group_availabilities_path(@token), params: {
        availability: {
          person_id: people(:alice).id,
          date: Date.current,
          status: "disponivel"
        }
      }
    end
    assert_redirected_to group_calendar_path(@token)
  end

  test "create with invalid data re-renders form" do
    assert_no_difference "Availability.count" do
      post group_availabilities_path(@token), params: {
        availability: {
          person_id: people(:alice).id,
          date: nil,
          status: ""
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    availability = availabilities(:alice_disponivel)
    get edit_group_availability_path(@token, availability)
    assert_response :success
  end

  test "update modifies availability" do
    person = people(:alice)
    availability = person.availabilities.create!(
      date: Date.current,
      status: "disponivel"
    )
    patch group_availability_path(@token, availability), params: {
      availability: {
        person_id: person.id,
        status: "ocupado",
        date: availability.date
      }
    }
    assert_redirected_to group_calendar_path(@token)
    assert_equal "ocupado", availability.reload.status
  end

  test "destroy removes availability" do
    availability = availabilities(:alice_disponivel)
    assert_difference "Availability.count", -1 do
      delete group_availability_path(@token, availability)
    end
    assert_redirected_to group_calendar_path(@token)
  end

  test "redirects when no people in group" do
    group = Group.create!(name: "Empty Group")
    get new_group_availability_path(group.share_token)
    assert_redirected_to new_group_person_path(group.share_token)
  end
end

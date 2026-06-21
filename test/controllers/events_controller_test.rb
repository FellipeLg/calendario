require "test_helper"

class EventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = groups(:hexatombe).share_token
    @alice = people(:alice)
    @bob = people(:bob)
  end

  test "new renders form" do
    get new_group_event_path(@token)
    assert_response :success
    assert_select "h1", "Novo evento"
  end

  test "create adds event with participants" do
    assert_difference "Event.count", 1 do
      post group_events_path(@token), params: {
        event: {
          title: "Churrasco",
          starts_at: 3.days.from_now.change(hour: 18),
          ends_at: 3.days.from_now.change(hour: 22),
          person_ids: [ @alice.id, @bob.id ]
        }
      }
    end
    assert_redirected_to group_calendar_path(@token)
    event = Event.last
    assert_equal "Churrasco", event.title
    assert_equal 2, event.people.count
  end

  test "create with invalid data re-renders form" do
    assert_no_difference "Event.count" do
      post group_events_path(@token), params: {
        event: {
          title: "",
          starts_at: nil,
          ends_at: nil,
          person_ids: []
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "edit renders form" do
    event = events(:sessao)
    get edit_group_event_path(@token, event)
    assert_response :success
  end

  test "update modifies event" do
    event = events(:sessao)
    patch group_event_path(@token, event), params: {
      event: {
        title: "Nova Sessão",
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        person_ids: event.people.map(&:id)
      }
    }
    assert_redirected_to group_calendar_path(@token)
    assert_equal "Nova Sessão", event.reload.title
  end

  test "destroy removes event" do
    event = events(:sessao)
    assert_difference "Event.count", -1 do
      delete group_event_path(@token, event)
    end
    assert_redirected_to group_calendar_path(@token)
  end

  test "feed returns JSON" do
    get group_feed_path(@token, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert_kind_of Array, json
  end

  test "feed with date range" do
    get group_feed_path(@token, format: :json, start: 1.week.ago.to_date, end: 1.month.from_now.to_date)
    assert_response :success
  end

  test "redirects when no people in group" do
    group = Group.create!(name: "Empty Group")
    get new_group_event_path(group.share_token)
    assert_redirected_to new_group_person_path(group.share_token)
  end
end

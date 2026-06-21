require "test_helper"

class GroupFlowTest < ActionDispatch::IntegrationTest
  test "complete flow: create group, add people, create availability, create event" do
    # 1. Access home and get redirected to group
    get root_path
    group = Group.first
    assert_redirected_to group_calendar_path(group.share_token)

    # 2. View dashboard
    follow_redirect!
    assert_response :success
    assert_select "h1", group.name

    # 3. Add first person
    token = group.share_token
    get new_group_person_path(token)
    assert_response :success

    post group_people_path(token), params: {
      person: { name: "Alice", contact: "alice@test", color: "#a8323e" }
    }
    assert_redirected_to group_calendar_path(token)
    follow_redirect!
    assert_select ".person-row"

    # 4. Add second person
    post group_people_path(token), params: {
      person: { name: "Bob", contact: "bob@test", color: "#4b7aa0" }
    }
    assert_redirected_to group_calendar_path(token)

    # 5. Add availability for Alice
    alice = Person.find_by!(name: "Alice")
    get new_group_availability_path(token)
    assert_response :success

    post group_availabilities_path(token), params: {
      availability: {
        person_id: alice.id,
        date: Date.current,
        status: "disponivel"
      }
    }
    assert_redirected_to group_calendar_path(token)

    # 6. Add availability for Bob
    bob = Person.find_by!(name: "Bob")
    post group_availabilities_path(token), params: {
      availability: {
        person_id: bob.id,
        date: Date.current,
        start_time: "09:00",
        end_time: "17:00",
        status: "trabalhando"
      }
    }
    assert_redirected_to group_calendar_path(token)

    # 7. Create event
    get new_group_event_path(token)
    assert_response :success

    post group_events_path(token), params: {
      event: {
        title: "Sessão de RPG",
        starts_at: 2.days.from_now.change(hour: 20),
        ends_at: 2.days.from_now.change(hour: 23),
        person_ids: [alice.id, bob.id]
      }
    }
    assert_redirected_to group_calendar_path(token)

    event = Event.find_by!(title: "Sessão de RPG")
    assert_equal 2, event.people.count

    # 8. View feed JSON
    get group_feed_path(token, format: :json)
    assert_response :success
    json = JSON.parse(response.body)
    assert json.length >= 3 # 2 availabilities + 1 event
  end

  test "editing availability" do
    group = groups(:hexatombe)
    token = group.share_token
    alice = people(:alice)

    availability = alice.availabilities.create!(
      date: Date.current,
      status: "disponivel"
    )

    get edit_group_availability_path(token, availability)
    assert_response :success

    patch group_availability_path(token, availability), params: {
      availability: {
        person_id: alice.id,
        date: availability.date,
        status: "ocupado"
      }
    }
    assert_redirected_to group_calendar_path(token)
    assert_equal "ocupado", availability.reload.status
  end

  test "deleting availability" do
    group = groups(:hexatombe)
    token = group.share_token
    alice = people(:alice)

    availability = alice.availabilities.create!(
      date: Date.current,
      status: "disponivel"
    )

    assert_difference "Availability.count", -1 do
      delete group_availability_path(token, availability)
    end
    assert_redirected_to group_calendar_path(token)
  end

  test "editing event" do
    group = groups(:hexatombe)
    token = group.share_token
    event = events(:sessao)

    get edit_group_event_path(token, event)
    assert_response :success

    patch group_event_path(token, event), params: {
      event: {
        title: "Sessão Atualizada",
        starts_at: event.starts_at,
        ends_at: event.ends_at,
        person_ids: event.people.map(&:id)
      }
    }
    assert_redirected_to group_calendar_path(token)
    assert_equal "Sessão Atualizada", event.reload.title
  end

  test "deleting event" do
    group = groups(:hexatombe)
    token = group.share_token
    event = events(:sessao)

    assert_difference "Event.count", -1 do
      delete group_event_path(token, event)
    end
    assert_redirected_to group_calendar_path(token)
  end

  test "share URL is displayed on dashboard" do
    group = groups(:hexatombe)
    get group_calendar_path(group.share_token)
    assert_select "input[value=?]", group_calendar_url(group.share_token)
  end

  test "calendar feed includes availability and event data" do
    group = groups(:hexatombe)
    token = group.share_token

    get group_feed_path(token, format: :json)
    assert_response :success

    json = JSON.parse(response.body)
    kinds = json.map { |item| item["classNames"] }.flatten
    assert kinds.any? { |c| c.include?("kind-availability") }
    assert kinds.any? { |c| c.include?("kind-event") }
  end
end

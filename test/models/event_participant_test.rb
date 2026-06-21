require "test_helper"

class EventParticipantTest < ActiveSupport::TestCase
  test "valid event participant" do
    event = Event.create!(
      group: groups(:hexatombe),
      title: "Novo Evento",
      starts_at: 3.days.from_now,
      ends_at: 3.days.from_now + 2.hours,
      people: [ people(:alice) ]
    )
    participant = EventParticipant.new(event: event, person: people(:bob))
    assert participant.valid?
  end

  test "invalid duplicate participant" do
    participant = EventParticipant.new(
      event: events(:sessao),
      person: people(:alice)
    )
    assert_not participant.valid?
    assert participant.errors[:person_id].any?
  end

  test "invalid person from different group" do
    participant = EventParticipant.new(
      event: events(:sessao),
      person: people(:carol)
    )
    assert_not participant.valid?
    assert participant.errors[:person].any? { |msg| msg.include?("pertencer") }
  end

  test "belongs to event" do
    participant = event_participants(:alice_na_sessao)
    assert_equal events(:sessao), participant.event
  end

  test "belongs to person" do
    participant = event_participants(:alice_na_sessao)
    assert_equal people(:alice), participant.person
  end
end

require "test_helper"

class EventTest < ActiveSupport::TestCase
  setup do
    @group = groups(:hexatombe)
    @alice = people(:alice)
    @bob = people(:bob)
  end

  test "valid event with participants" do
    event = Event.new(
      group: @group,
      title: "Churrasco",
      starts_at: 2.days.from_now,
      ends_at: 2.days.from_now + 3.hours
    )
    event.people = [ @alice, @bob ]
    assert event.valid?
  end

  test "invalid without title" do
    event = Event.new(group: @group, starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)
    event.people = [ @alice ]
    assert_not event.valid?
    assert event.errors[:title].any?
  end

  test "invalid without starts_at" do
    event = Event.new(group: @group, title: "Test", ends_at: 2.days.from_now + 1.hour)
    event.people = [ @alice ]
    assert_not event.valid?
    assert event.errors[:starts_at].any?
  end

  test "invalid without ends_at" do
    event = Event.new(group: @group, title: "Test", starts_at: 2.days.from_now)
    event.people = [ @alice ]
    assert_not event.valid?
    assert event.errors[:ends_at].any?
  end

  test "invalid when ends_at before starts_at" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: 2.days.from_now + 2.hours,
      ends_at: 2.days.from_now
    )
    event.people = [ @alice ]
    assert_not event.valid?
    assert event.errors[:ends_at].any?
  end

  test "invalid without participants" do
    event = Event.new(group: @group, title: "Test", starts_at: 2.days.from_now, ends_at: 2.days.from_now + 1.hour)
    assert_not event.valid?
    assert event.errors[:base].any?
  end

  test "invalid with participant from different group" do
    carol = people(:carol)
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: 2.days.from_now,
      ends_at: 2.days.from_now + 1.hour
    )
    event.people = [ @alice, carol ]
    assert_not event.valid?
    assert event.errors[:base].any? { |msg| msg.include?("pertencer") }
  end

  test "chronological scope" do
    events = Event.chronological
    starts = events.map(&:starts_at)
    assert_equal starts.sort, starts
  end

  test "calendar_color returns first participant color" do
    event = events(:sessao)
    assert_equal @alice.color, event.calendar_color
  end

  test "calendar_color defaults to red" do
    event = Event.new(people: [])
    assert_equal "#a8323e", event.calendar_color
  end

  test "conflict_records finds overlapping availabilities" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 10, 0),
      ends_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 16, 0)
    )
    event.people = [ @bob ]
    conflicts = event.conflict_records
    assert conflicts.any? { |c| c.status == "trabalhando" }
  end

  test "conflict_records empty when no overlap" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 18, 0),
      ends_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 20, 0)
    )
    event.people = [ @bob ]
    assert_empty event.conflict_records
  end

  test "conflict_messages formats correctly" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 10, 0),
      ends_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 16, 0)
    )
    event.people = [ @bob ]
    messages = event.conflict_messages
    assert messages.any? { |m| m.include?("Bob") }
  end

  test "conflicts_must_be_confirmed validation" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 10, 0),
      ends_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 16, 0),
      conflict_confirmed: false
    )
    event.people = [ @bob ]
    assert_not event.valid?
    assert event.errors[:base].any? { |msg| msg.include?("conflito") }
  end

  test "can save with conflict when confirmed" do
    event = Event.new(
      group: @group,
      title: "Test",
      starts_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 10, 0),
      ends_at: Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 16, 0),
      conflict_confirmed: true
    )
    event.people = [ @bob ]
    assert event.valid?
  end

  test "belongs to group" do
    event = events(:sessao)
    assert_equal @group, event.group
  end

  test "has many people through event_participants" do
    event = events(:sessao)
    assert_includes event.people, @alice
    assert_includes event.people, @bob
  end
end

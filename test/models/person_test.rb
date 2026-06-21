require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "valid person with name and color" do
    person = Person.new(name: "Dave", color: "#a8323e", group: groups(:hexatombe))
    assert person.valid?
  end

  test "invalid without name" do
    person = Person.new(name: nil, color: "#a8323e")
    assert_not person.valid?
    assert person.errors[:name].any?
  end

  test "assigns default color when color is nil" do
    person = Person.new(name: "Dave", color: nil)
    person.valid?
    assert_match(/\A#[0-9a-fA-F]{6}\z/, person.color)
  end

  test "invalid color format" do
    person = Person.new(name: "Dave", color: "red")
    person.valid?
    assert person.errors[:color].any?
  end

  test "valid hex color" do
    person = Person.new(name: "Dave", color: "#ABC123", group: groups(:hexatombe))
    assert person.valid?
  end

  test "initials from single name" do
    person = Person.new(name: "Alice")
    assert_equal "A", person.initials
  end

  test "initials from full name" do
    person = Person.new(name: "Alice Smith")
    assert_equal "AS", person.initials
  end

  test "initials caps at 2 characters" do
    person = Person.new(name: "Alice Bob Carol")
    assert_equal "AB", person.initials
  end

  test "belongs to group" do
    person = people(:alice)
    assert_equal groups(:hexatombe), person.group
  end

  test "has many availabilities" do
    person = people(:alice)
    assert_respond_to person, :availabilities
  end

  test "destroying person destroys availabilities" do
    person = people(:alice)
    assert_difference "Availability.count", -person.availabilities.count do
      person.destroy
    end
  end

  test "destroying person destroys event_participants" do
    person = people(:alice)
    assert_difference "EventParticipant.count", -person.event_participants.count do
      person.destroy
    end
  end
end

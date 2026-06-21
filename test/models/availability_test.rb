require "test_helper"

class AvailabilityTest < ActiveSupport::TestCase
  test "valid availability with required fields" do
    availability = Availability.new(
      person: people(:alice),
      date: Date.current,
      status: "disponivel"
    )
    assert availability.valid?
  end

  test "invalid without date" do
    availability = Availability.new(person: people(:alice), status: "disponivel")
    assert_not availability.valid?
    assert availability.errors[:date].any?
  end

  test "invalid without status" do
    availability = Availability.new(person: people(:alice), date: Date.current)
    assert_not availability.valid?
    assert availability.errors[:status].any?
  end

  test "invalid status not in list" do
    availability = Availability.new(person: people(:alice), date: Date.current, status: "invalido")
    assert_not availability.valid?
    assert availability.errors[:status].any?
  end

  test "all valid statuses" do
    Availability::STATUSES.each_key do |status|
      availability = Availability.new(person: people(:alice), date: Date.current, status: status)
      assert availability.valid?, "Status #{status} should be valid"
    end
  end

  test "full_day when no times" do
    availability = Availability.new(start_time: nil, end_time: nil)
    assert availability.full_day?
  end

  test "not full_day when times present" do
    availability = Availability.new(
      start_time: Time.zone.local(2026, 1, 1, 9, 0),
      end_time: Time.zone.local(2026, 1, 1, 17, 0)
    )
    assert_not availability.full_day?
  end

  test "invalid when only start_time provided" do
    availability = Availability.new(
      person: people(:alice),
      date: Date.current,
      status: "disponivel",
      start_time: Time.zone.local(2026, 1, 1, 9, 0),
      end_time: nil
    )
    assert_not availability.valid?
    assert availability.errors[:base].any?
  end

  test "invalid when only end_time provided" do
    availability = Availability.new(
      person: people(:alice),
      date: Date.current,
      status: "disponivel",
      start_time: nil,
      end_time: Time.zone.local(2026, 1, 1, 17, 0)
    )
    assert_not availability.valid?
  end

  test "invalid when end_time before start_time" do
    availability = Availability.new(
      person: people(:alice),
      date: Date.current,
      status: "disponivel",
      start_time: Time.zone.local(2026, 1, 1, 17, 0),
      end_time: Time.zone.local(2026, 1, 1, 9, 0)
    )
    assert_not availability.valid?
    assert availability.errors[:end_time].any?
  end

  test "chronological scope orders by date then start_time" do
    availabilities = Availability.chronological
    dates = availabilities.map(&:date)
    assert_equal dates.sort, dates
  end

  test "status_label returns human readable" do
    availability = Availability.new(status: "disponivel")
    assert_equal "Disponivel", availability.status_label
  end

  test "overlaps? detects overlap" do
    availability = availabilities(:bob_trabalhando)
    range_start = Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 12, 0)
    range_end = Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 14, 0)
    assert availability.overlaps?(range_start, range_end)
  end

  test "overlaps? no overlap" do
    availability = availabilities(:bob_trabalhando)
    range_start = Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 18, 0)
    range_end = Time.zone.local(Date.current.year, Date.current.month, Date.current.day, 20, 0)
    assert_not availability.overlaps?(range_start, range_end)
  end

  test "belongs to person" do
    availability = availabilities(:alice_disponivel)
    assert_equal people(:alice), availability.person
  end
end

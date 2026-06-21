require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "valid group with name" do
    group = Group.new(name: "Novo Grupo")
    assert group.valid?
  end

  test "invalid without name" do
    group = Group.new(name: nil)
    assert_not group.valid?
    assert group.errors[:name].any?
  end

  test "assigns share_token on create" do
    group = Group.create!(name: "Teste")
    refute_nil group.share_token
    assert group.share_token.length > 10
  end

  test "share_token is unique" do
    group1 = Group.create!(name: "G1")
    group2 = Group.create!(name: "G2")
    assert_not_equal group1.share_token, group2.share_token
  end

  test "share_token is preserved if provided" do
    group = Group.create!(name: "G", share_token: "custom_token")
    assert_equal "custom_token", group.share_token
  end

  test "has many people" do
    group = groups(:hexatombe)
    assert_respond_to group, :people
    assert group.people.count >= 2
  end

  test "has many events" do
    group = groups(:hexatombe)
    assert_respond_to group, :events
  end

  test "destroying group destroys people" do
    group = Group.create!(name: "Temp")
    group.people.create!(name: "P1", color: "#a8323e")
    assert_difference "Person.count", -1 do
      group.destroy
    end
  end

  test "destroying group destroys events" do
    group = groups(:hexatombe)
    assert_difference "Event.count", -group.events.count do
      group.destroy
    end
  end
end

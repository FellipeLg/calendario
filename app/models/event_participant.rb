class EventParticipant < ApplicationRecord
  belongs_to :event
  belongs_to :person

  validates :person_id, uniqueness: { scope: :event_id }
  validate :person_belongs_to_event_group

  private

  def person_belongs_to_event_group
    return if event.blank? || person.blank? || event.group_id == person.group_id

    errors.add(:person, "precisa pertencer ao mesmo grupo do evento.")
  end
end

class Event < ApplicationRecord
  belongs_to :group
  has_many :event_participants, dependent: :destroy
  has_many :people, through: :event_participants

  validates :title, :starts_at, :ends_at, presence: true
  validate :ends_after_start
  validate :participants_required
  validate :participants_from_group
  validate :conflicts_must_be_confirmed

  scope :chronological, -> { order(starts_at: :asc, ends_at: :asc) }

  def conflict_records
    return [] if starts_at.blank? || ends_at.blank? || people.empty?

    Availability.includes(:person)
      .where(person_id: people.map(&:id), status: Availability::CONFLICT_STATUSES)
      .where(date: starts_at.to_date..ends_at.to_date)
      .select { |availability| availability.overlaps?(starts_at, ends_at) }
  end

  def conflict_messages
    conflict_records.map do |availability|
      "#{availability.person.name}: #{availability.status_label} em #{I18n.l(availability.date)}"
    end
  end

  def calendar_color
    people.first&.color || "#a8323e"
  end

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "deve ser depois do inicio.")
  end

  def participants_required
    return if people.any?

    errors.add(:base, "Escolha pelo menos uma pessoa.")
  end

  def participants_from_group
    return if group.blank? || people.all? { |person| person.group_id == group_id }

    errors.add(:base, "Todas as pessoas precisam pertencer a este grupo.")
  end

  def conflicts_must_be_confirmed
    return if conflict_confirmed? || conflict_records.empty?

    errors.add(:base, "Existe conflito de horario. Marque a confirmacao para salvar mesmo assim.")
  end
end

class Availability < ApplicationRecord
  STATUSES = {
    "disponivel" => "Disponivel",
    "trabalhando" => "Trabalhando",
    "ocupado" => "Ocupado",
    "indisponivel" => "Indisponivel",
    "compromisso" => "Outro compromisso"
  }.freeze

  CONFLICT_STATUSES = %w[trabalhando ocupado indisponivel compromisso].freeze

  belongs_to :person

  validates :date, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES.keys }
  validate :time_fields_match
  validate :end_time_after_start_time

  scope :chronological, -> { order(date: :asc, start_time: :asc, created_at: :asc) }

  def full_day?
    start_time.blank? && end_time.blank?
  end

  def starts_at
    return if date.blank?

    build_datetime(start_time || Time.zone.local(date.year, date.month, date.day))
  end

  def ends_at
    return if date.blank?

    if full_day?
      Time.zone.local(date.year, date.month, date.day).advance(days: 1)
    else
      build_datetime(end_time)
    end
  end

  def overlaps?(range_start, range_end)
    starts_at.present? && ends_at.present? && starts_at < range_end && ends_at > range_start
  end

  def status_label
    STATUSES.fetch(status, status.to_s.humanize)
  end

  private

  def time_fields_match
    return if start_time.blank? == end_time.blank?

    errors.add(:base, "Informe o horario inicial e final, ou deixe ambos em branco.")
  end

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank? || end_time > start_time

    errors.add(:end_time, "deve ser depois do horario inicial.")
  end

  def build_datetime(time_value)
    Time.zone.local(date.year, date.month, date.day, time_value.hour, time_value.min)
  end
end

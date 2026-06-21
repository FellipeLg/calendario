module ApplicationHelper
  def flash_class(type)
    type.to_s == "alert" ? "flash flash-alert" : "flash flash-notice"
  end

  def status_options
    Availability::STATUSES.map { |value, label| [ label, value ] }
  end

  def datetime_field_value(value)
    value&.strftime("%Y-%m-%dT%H:%M")
  end

  def time_field_value(value)
    value&.strftime("%H:%M")
  end

  def selected_person_ids(event)
    event.people.map(&:id).map(&:to_s)
  end
end

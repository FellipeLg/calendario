class EventsController < ApplicationController
  before_action :set_group
  before_action :require_people, except: :feed
  before_action :set_event, only: %i[edit update destroy]

  def new
    @event = @group.events.new(
      starts_at: 1.hour.from_now.change(min: 0),
      ends_at: 2.hours.from_now.change(min: 0)
    )
  end

  def create
    form_params = event_form_params
    @event = @group.events.new(event_attributes(form_params))
    assign_event_people(@event, form_params)
    @conflicts = @event.conflict_records

    if @event.save
      redirect_to_group(notice: "Evento criado.")
    else
      @conflicts = @event.conflict_records
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @conflicts = @event.conflict_records
  end

  def update
    form_params = event_form_params
    @event.assign_attributes(event_attributes(form_params))
    assign_event_people(@event, form_params)
    @conflicts = @event.conflict_records

    if @event.save
      redirect_to_group(notice: "Evento atualizado.")
    else
      @conflicts = @event.conflict_records
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy

    redirect_to_group(notice: "Evento removido.")
  end

  def feed
    range_start = parse_calendar_time(params[:start]) || 1.month.ago
    range_end = parse_calendar_time(params[:end]) || 2.months.from_now

    render json: availability_feed(range_start, range_end) + event_feed(range_start, range_end)
  end

  private

  def require_people
    return if @group.people.exists?

    redirect_to new_group_person_path(@group.share_token), alert: "Cadastre uma pessoa antes de criar eventos."
  end

  def set_event
    @event = @group.events.find(params[:id])
  end

  def event_form_params
    params.require(:event).permit(:title, :starts_at, :ends_at, :note, :conflict_confirmed, person_ids: [])
  end

  def event_attributes(form_params)
    form_params.except(:person_ids)
  end

  def assign_event_people(event, form_params)
    ids = Array(form_params[:person_ids]).reject(&:blank?)
    event.people = @group.people.where(id: ids)
  end

  def parse_calendar_time(value)
    Time.zone.parse(value.to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def availability_feed(range_start, range_end)
    @group.availabilities.includes(:person)
      .where(date: range_start.to_date..range_end.to_date)
      .map { |availability| availability_calendar_payload(availability) }
  end

  def event_feed(range_start, range_end)
    @group.events.includes(:people)
      .where("starts_at < ? AND ends_at > ?", range_end, range_start)
      .map { |event| event_calendar_payload(event) }
  end

  def availability_calendar_payload(availability)
    {
      id: "availability-#{availability.id}",
      title: "#{availability.person.name}: #{availability.status_label}",
      start: availability.full_day? ? availability.date.iso8601 : availability.starts_at.iso8601,
      end: availability.full_day? ? availability.date.next_day.iso8601 : availability.ends_at.iso8601,
      allDay: availability.full_day?,
      color: availability.person.color,
      classNames: [ "status-#{availability.status}", "kind-availability" ],
      url: edit_group_availability_path(@group.share_token, availability)
    }
  end

  def event_calendar_payload(event)
    {
      id: "event-#{event.id}",
      title: event.title,
      start: event.starts_at.iso8601,
      end: event.ends_at.iso8601,
      color: event.calendar_color,
      classNames: [ "kind-event" ],
      url: edit_group_event_path(@group.share_token, event)
    }
  end
end

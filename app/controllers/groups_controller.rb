class GroupsController < ApplicationController
  before_action :set_group, only: :show

  def home
    group = Group.first_or_create!(name: "Agenda Hexatombe")

    redirect_to group_calendar_path(group.share_token)
  end

  def show
    @people = @group.people.order(:name)
    @availabilities = @group.availabilities.includes(:person).chronological
      .where(date: Date.current..30.days.from_now.to_date)
      .limit(12)
    @events = @group.events.includes(:people).chronological
      .where("ends_at >= ?", Time.zone.now.beginning_of_day)
      .limit(12)
  end
end

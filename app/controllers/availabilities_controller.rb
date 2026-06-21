class AvailabilitiesController < ApplicationController
  before_action :set_group
  before_action :require_people, only: %i[new create edit update]
  before_action :set_availability, only: %i[edit update destroy]

  def new
    @availability = Availability.new(date: params[:date] || Date.current, status: "disponivel")
  end

  def create
    form_params = availability_form_params
    @availability = selected_person(form_params).availabilities.new(availability_attributes(form_params))

    if @availability.save
      redirect_to_group(notice: "Disponibilidade registrada.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    form_params = availability_form_params
    @availability.person = selected_person(form_params)
    @availability.assign_attributes(availability_attributes(form_params))

    if @availability.save
      redirect_to_group(notice: "Disponibilidade atualizada.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @availability.destroy

    redirect_to_group(notice: "Disponibilidade removida.")
  end

  private

  def require_people
    return if @group.people.exists?

    redirect_to new_group_person_path(@group.share_token), alert: "Cadastre uma pessoa antes de registrar agenda."
  end

  def set_availability
    @availability = @group.availabilities.find(params[:id])
  end

  def selected_person(form_params)
    @group.people.find(form_params.delete(:person_id))
  end

  def availability_attributes(form_params)
    form_params.except(:person_id)
  end

  def availability_form_params
    params.require(:availability).permit(:person_id, :date, :start_time, :end_time, :status, :note)
  end
end

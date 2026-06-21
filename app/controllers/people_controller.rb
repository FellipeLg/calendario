class PeopleController < ApplicationController
  before_action :set_group
  before_action :set_person, only: %i[edit update destroy]

  def new
    @person = @group.people.new
  end

  def create
    @person = @group.people.new(person_params)

    if @person.save
      redirect_to_group(notice: "Pessoa adicionada ao grupo.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @person.update(person_params)
      redirect_to_group(notice: "Pessoa atualizada.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @person.destroy

    redirect_to_group(notice: "Pessoa removida.")
  end

  private

  def set_person
    @person = @group.people.find(params[:id])
  end

  def person_params
    params.require(:person).permit(:name, :contact, :color)
  end
end

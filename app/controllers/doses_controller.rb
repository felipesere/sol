class DosesController < ApplicationController
  include ChildScoped

  before_action :set_dose, only: %i[edit update destroy]

  def new
    @medicine = medicine_from(params[:medicine_id])
    @dose = @child.doses.new(medicine: @medicine, amount: @medicine&.dose_amount, given_at: Time.current)
  end

  def create
    @dose = @child.doses.new(dose_params.merge(user: current_user))
    @medicine = @dose.medicine
    if @dose.save
      redirect_to child_path(@child), notice: "#{@dose.medicine.name} recorded"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @medicine = @dose.medicine
  end

  def update
    @medicine = @dose.medicine
    if @dose.update(dose_params.except(:medicine_id))
      redirect_to child_path(@child), notice: "Dose updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dose.destroy
    redirect_to child_path(@child), notice: "Dose deleted"
  end

  private

  def set_dose
    @dose = @child.doses.find(params[:id])
  end

  def medicine_from(id)
    medicines = @child.medicines.active
    medicines.find_by(id: id) || medicines.order(:id).first
  end

  def dose_params
    permitted = params.expect(dose: %i[medicine_id amount given_at notes])
    permitted[:medicine_id] = @child.medicines.find(permitted[:medicine_id]).id if permitted[:medicine_id]
    permitted
  end
end

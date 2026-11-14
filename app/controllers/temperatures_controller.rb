class TemperaturesController < ApplicationController
  include ChildScoped

  before_action :set_temperature, only: %i[edit update destroy]

  def new
    @temperature = @child.temperatures.new(measured_at: Time.current)
  end

  def create
    @temperature = @child.temperatures.new(temperature_params.merge(user: current_user))
    if @temperature.save
      redirect_to child_path(@child), notice: "Temperature saved"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @temperature.update(temperature_params)
      redirect_to child_path(@child), notice: "Temperature updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @temperature.destroy
    redirect_to child_path(@child), notice: "Temperature deleted"
  end

  private

  def set_temperature
    @temperature = @child.temperatures.find(params[:id])
  end

  def temperature_params
    params.expect(temperature: %i[celsius measured_at notes])
  end
end

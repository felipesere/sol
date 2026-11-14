class MedicinesController < ApplicationController
  include ChildScoped

  before_action :set_medicine, only: %i[edit update]

  def index
    @medicines = @child.medicines.order(:id)
  end

  def new
    @medicine = @child.medicines.new(dose_unit: "ml")
  end

  def create
    @medicine = @child.medicines.new(medicine_params)
    if @medicine.save
      redirect_to child_medicines_path(@child), notice: "#{@medicine.name} added"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @medicine.update(medicine_params)
      redirect_to child_medicines_path(@child), notice: "#{@medicine.name} updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_medicine
    @medicine = @child.medicines.find(params[:id])
  end

  def medicine_params
    params.expect(medicine: %i[name dose_amount dose_unit min_interval_minutes max_doses_per_24h active])
  end
end

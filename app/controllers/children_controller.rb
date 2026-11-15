class ChildrenController < ApplicationController
  before_action :set_child, only: %i[show edit update]

  def index
    first = Child.order(:id).first
    redirect_to first ? child_path(first) : new_child_path
  end

  def show
    @range = params[:range] == "48" ? 48 : 24
    @statuses = @child.medicines.active.order(:id).map(&:status)
    @latest = @child.temperatures.newest_first.first
    @peak = @child.temperatures.where(measured_at: 24.hours.ago..).order(celsius: :desc, measured_at: :desc).first
    @timeline = Timeline.new(@child)
    @chart = ChartData.new(@child, hours: @range)
  end

  def new
    @child = Child.new
  end

  def create
    @child = Child.new(child_params)
    if @child.save
      redirect_to child_medicines_path(@child), notice: "#{@child.name} added. Now add the medicines you use."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @child.update(child_params)
      redirect_to child_path(@child)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_child
    @child = Child.find(params[:id])
  end

  def child_params
    params.expect(child: %i[name birth_date])
  end
end

class AddScheduleToMedicines < ActiveRecord::Migration[8.1]
  def change
    add_column :medicines, :kind, :string, null: false, default: "as_needed"
    add_column :medicines, :doses_per_day, :integer
    add_column :medicines, :course_days, :integer
    add_column :medicines, :started_on, :date
    change_column_null :medicines, :max_doses_per_24h, true
  end
end

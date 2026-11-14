class CreateMedicines < ActiveRecord::Migration[8.1]
  def change
    create_table :medicines do |t|
      t.references :child, null: false, foreign_key: true
      t.string :name, null: false
      t.decimal :dose_amount, precision: 6, scale: 2, null: false
      t.string :dose_unit, null: false, default: "ml"
      t.integer :min_interval_minutes, null: false
      t.integer :max_doses_per_24h, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end

class CreateTemperatures < ActiveRecord::Migration[8.1]
  def change
    create_table :temperatures do |t|
      t.references :child, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :measured_at, null: false
      t.decimal :celsius, precision: 3, scale: 1, null: false
      t.text :notes

      t.timestamps
    end
    add_index :temperatures, [:child_id, :measured_at]
  end
end

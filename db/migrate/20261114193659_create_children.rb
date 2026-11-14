class CreateChildren < ActiveRecord::Migration[8.1]
  def change
    create_table :children do |t|
      t.string :name, null: false
      t.date :birth_date

      t.timestamps
    end
  end
end

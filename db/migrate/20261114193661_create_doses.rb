class CreateDoses < ActiveRecord::Migration[8.1]
  def change
    create_table :doses do |t|
      t.references :child, null: false, foreign_key: true
      t.references :medicine, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.datetime :given_at, null: false
      t.decimal :amount, precision: 6, scale: 2, null: false
      t.text :notes

      t.timestamps
    end
    add_index :doses, [:child_id, :given_at]
  end
end

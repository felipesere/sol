class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :sub
      t.string :email

      t.timestamps
    end
    add_index :users, :sub, unique: true
    add_index :users, :name
  end
end

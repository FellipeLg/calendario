class CreatePeople < ActiveRecord::Migration[8.1]
  def change
    create_table :people do |t|
      t.references :group, null: false, foreign_key: true
      t.string :name, null: false
      t.string :contact
      t.string :color, null: false

      t.timestamps
    end

    add_index :people, [ :group_id, :name ]
  end
end

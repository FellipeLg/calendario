class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.references :group, null: false, foreign_key: true
      t.string :title, null: false
      t.datetime :starts_at, null: false
      t.datetime :ends_at, null: false
      t.text :note
      t.boolean :conflict_confirmed, null: false, default: false

      t.timestamps
    end

    add_index :events, [ :group_id, :starts_at ]
  end
end

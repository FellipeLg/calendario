class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :person, null: false, foreign_key: true
      t.date :date, null: false
      t.time :start_time
      t.time :end_time
      t.string :status, null: false
      t.text :note

      t.timestamps
    end

    add_index :availabilities, [ :person_id, :date ]
    add_index :availabilities, :status
  end
end

class CreateEventParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :event_participants do |t|
      t.references :event, null: false, foreign_key: true
      t.references :person, null: false, foreign_key: true

      t.timestamps
    end

    add_index :event_participants, [ :event_id, :person_id ], unique: true
  end
end

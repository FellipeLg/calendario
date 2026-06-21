class CreateGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :groups do |t|
      t.string :name, null: false
      t.string :share_token, null: false

      t.timestamps
    end

    add_index :groups, :share_token, unique: true
  end
end

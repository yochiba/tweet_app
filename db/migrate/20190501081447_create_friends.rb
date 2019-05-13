class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.string :user_id
      t.integer :relation_code
      t.string :friend_id

      t.timestamps
    end
  end
end

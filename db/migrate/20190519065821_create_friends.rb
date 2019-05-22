class CreateFriends < ActiveRecord::Migration[5.2]
  def change
    create_table :friends do |t|
      t.string :user_id
      t.string :friend_id
      t.integer :friend_flg

      t.timestamps
    end
  end
end

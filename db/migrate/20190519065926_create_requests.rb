class CreateRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :requests do |t|
      t.string :user_id
      t.string :friend_id
      t.integer :pending_flg

      t.timestamps
    end
  end
end

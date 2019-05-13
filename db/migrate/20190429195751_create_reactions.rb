class CreateReactions < ActiveRecord::Migration[5.2]
  def change
    create_table :reactions do |t|
      t.string :user_id
      t.string :post_id

      t.timestamps
    end
  end
end

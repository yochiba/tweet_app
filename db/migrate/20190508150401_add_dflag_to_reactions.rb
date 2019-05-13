class AddDflagToReactions < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions, :d_flag, :integer, default: 1
  end
end

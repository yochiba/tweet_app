class AddBooleanFlagToReactions < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions, :delete_flag, :boolean, default: false, null: false
  end
end

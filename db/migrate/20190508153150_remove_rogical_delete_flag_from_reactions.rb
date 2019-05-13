class RemoveRogicalDeleteFlagFromReactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :reactions, :rogical_delete_flag, :boolean
  end
end

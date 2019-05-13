class RemoveFlagFromReavtion < ActiveRecord::Migration[5.2]
  def change
    remove_column :reactions, :delete_flag, :boolean
  end
end

class AddSampleFlgReaction < ActiveRecord::Migration[5.2]
  def change
    add_column :reactions, :rogical_delete_flag, :boolean, default: false
  end
end

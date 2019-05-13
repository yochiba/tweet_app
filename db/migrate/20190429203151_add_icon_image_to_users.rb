class AddIconImageToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :icon_image, :string
  end
end

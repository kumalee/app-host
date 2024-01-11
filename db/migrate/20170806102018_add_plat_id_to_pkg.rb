class AddPlatIdToPkg < ActiveRecord::Migration[7.1]
  def change
    add_column :pkgs, :plat_id, :integer
  end
end

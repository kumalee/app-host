class AddUniqKeyToPkg < ActiveRecord::Migration[7.1]
  def change
    add_column :pkgs, :uniq_key, :string
  end
end

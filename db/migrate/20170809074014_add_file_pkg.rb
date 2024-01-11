class AddFilePkg < ActiveRecord::Migration[7.1]
  def change
    add_column :pkgs, :file, :string
  end
end

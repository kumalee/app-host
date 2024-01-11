class RenamePackeagesToPkgs < ActiveRecord::Migration[7.1]
  def change
    rename_table :packages, :pkgs
  end
end
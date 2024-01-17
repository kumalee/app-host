class RenamePkgIdentToBundleId < ActiveRecord::Migration[7.1]
  def change
    rename_column :pkgs, :ident, :bundle_id
  end
end

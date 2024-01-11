class AddFeaturesToPkg < ActiveRecord::Migration[7.1]
  def change
    add_column :pkgs, :features, :string
  end
end

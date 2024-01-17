class AddValidateBundleIdToPlat < ActiveRecord::Migration[7.1]
  def change
    add_column :plats, :bundle_id, :string
  end
end

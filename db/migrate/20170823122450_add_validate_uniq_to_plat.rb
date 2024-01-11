class AddValidateUniqToPlat < ActiveRecord::Migration[7.1]
  def change
    add_column :plats, :pkg_uniq, :boolean, default: true
  end
end

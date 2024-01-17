class AddArchiveToApps < ActiveRecord::Migration[7.1]
  def change
    add_column :apps, :archived, :boolean, default:false
  end
end

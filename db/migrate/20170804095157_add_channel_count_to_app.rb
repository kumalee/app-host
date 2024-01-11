class AddChannelCountToApp < ActiveRecord::Migration[7.1]
  def change
    add_column :apps, :palts_count, :integer, default:0
    add_column :apps, :packages_count, :integer, default:0
  end
end

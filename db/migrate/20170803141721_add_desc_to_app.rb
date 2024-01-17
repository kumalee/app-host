class AddDescToApp < ActiveRecord::Migration[7.1]
  def change
    add_column :apps, :desc, :string
  end
end

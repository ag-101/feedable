class AddFeedDisplaySettingsToUser < ActiveRecord::Migration
  def change
     add_column :users, :feed_display_setting, :string
  end
end

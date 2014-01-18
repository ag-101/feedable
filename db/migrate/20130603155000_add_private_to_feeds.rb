class AddPrivateToFeeds < ActiveRecord::Migration
  def change
    add_column :feeds, :private, :boolean
  end
end

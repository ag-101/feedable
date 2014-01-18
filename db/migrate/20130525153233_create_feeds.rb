class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.string :image
      t.integer :user_id
      t.integer :feed_category_id
      t.string :feed_type
      t.string :colour

      t.timestamps
    end
  end
end

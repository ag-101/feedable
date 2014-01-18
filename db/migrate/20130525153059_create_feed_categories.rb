class CreateFeedCategories < ActiveRecord::Migration
  def change
    create_table :feed_categories do |t|
      t.string :name
      t.string :image
      t.string :colour
      t.integer :user_id

      t.timestamps
    end
  end
end

class CreateFeedContents < ActiveRecord::Migration
  def change
    create_table :feed_contents do |t|
      t.string :title
      t.string :url
      t.text :description
      t.datetime :pub_date
      t.integer :feed_id

      t.timestamps
    end
  end
end

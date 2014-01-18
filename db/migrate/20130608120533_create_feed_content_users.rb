class CreateFeedContentUsers < ActiveRecord::Migration
  def change    
    create_table :feed_content_users, :id => false do |t|
      t.references :feed_content, :null => false
      t.references :user, :null => false
    end
    
    add_index(:feed_content_users, [:feed_content_id, :user_id], :unique => true)
      

  end
end

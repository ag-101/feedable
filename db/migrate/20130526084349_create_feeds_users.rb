class CreateFeedsUsers < ActiveRecord::Migration
  def change
    create_table :feeds_users, :id => false do |t|
      t.references :feed, :null => false
      t.references :user, :null => false
    end
    
    add_index(:feeds_users, [:feed_id, :user_id], :unique => true)
  end
end
















class CreateRedirect < ActiveRecord::Migration
  def change    
    create_table :feed_content_redirects do |t|
      t.references :feed_content, :null => false
      t.references :user
      
      t.timestamps
    end

  end
end
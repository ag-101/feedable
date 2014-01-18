class AddLastVisitToUser < ActiveRecord::Migration
  def change
     add_column :users, :this_visit, :datetime
     add_column :users, :last_visit, :datetime
  end
end

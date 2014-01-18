class FeedCategory < ActiveRecord::Base
  has_many :feeds, :dependent => :delete_all  
  has_many :feed_content, :through=>:feeds, :dependent => :delete_all
  
  attr_accessible :colour, :created_by_id, :image, :name
  
  validates :name, :presence => true
end

class FeedContent < ActiveRecord::Base
  belongs_to :feed
  attr_accessible :description, :feed_id, :pub_date, :title, :url
  
  validates_uniqueness_of :title, :scope => :url
  
  has_many :user, :through => :feed_content_user
  has_many :feed_content_user, :dependent => :delete_all
  
  has_many :feed_content_redirect, :dependent => :delete_all
  
  validates_uniqueness_of :url, :scope => :title
end

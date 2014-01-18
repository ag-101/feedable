class Feed < ActiveRecord::Base
  has_many :feed_content, :dependent => :delete_all

  belongs_to :feed_category
  has_many :feed_user
  has_many :user, :through => :feed_user
  
  attr_accessible :feed_category_id, :colour, :user_id, :image, :name, :feed_type, :url, :private
  
  validates :name, :url, :type, :feed_category_id, :presence => true
  validates :url, :format => URI::regexp(%w(http https))
  validates_uniqueness_of :url
end

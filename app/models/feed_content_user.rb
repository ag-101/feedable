class FeedContentUser < ActiveRecord::Base
  belongs_to :feed_content
  belongs_to :user
end

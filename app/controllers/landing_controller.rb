class LandingController < ApplicationController
  def index
    if user_signed_in? and current_user.roles.where(:name => ['Registered','Admin']).present?
      redirect_to feeds_path
    end
    
    compute_tags
    
      @no_pagination = true
          
      @feed_content = FeedContent.joins('JOIN feeds on feed_contents.feed_id = feeds.id').where('feeds.private IS NULL OR feeds.private = 0').order('feed_contents.pub_date DESC').page(params[:page]).per(30)

  end
end

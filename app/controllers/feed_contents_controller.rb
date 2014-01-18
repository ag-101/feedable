class FeedContentsController < ApplicationController
  
  before_filter :verify_user, :except => [:redirect]
  
  def redirect
    @feed_content = FeedContent.find_by_id(params[:feed_content_id])
    
    redirect_item = FeedContentRedirect.new
    
    redirect_item.feed_content_id = @feed_content.id
    

    
    redirect_item.user_id = current_user.id if user_signed_in?
    
    redirect_item.save
    
    redirect_to(@feed_content.url)
  end
  
  def save
    
    saved_item = FeedContentUser.where('feed_content_id = ? and user_id = ?', params[:feed_content_id], current_user.id)
    if saved_item.count > 0
      saved_item.each do |fcu|
        ActiveRecord::Base.establish_connection
        ActiveRecord::Base.connection.execute("DELETE FROM `feed_content_users` WHERE feed_content_id = #{ fcu.feed_content_id } AND user_id = #{ fcu.user_id }")
      end
      
      saved_message = "unsaved"
      
    else

      save_item = FeedContentUser.new
      
      feed_content = FeedContent.find_by_id(params[:feed_content_id])
      
      save_item.user_id = current_user.id
      save_item.feed_content_id = feed_content.id
      if save_item.save
        saved_message = "saved"
      else
        saved_message = "There was an error saving the item."
      end
    
    end
    
    respond_to do |format|
        #format.html { redirect_to feeds_path, :notice => ("#{count} new items" if count > 0) }
        format.json { render :text => saved_message, :status => :ok }
    end
  end
end

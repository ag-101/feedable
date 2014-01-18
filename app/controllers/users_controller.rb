class UsersController < ApplicationController
  def index
  end

  def show

    @user = User.find_by_id(params[:id])
    if @user
      if user_signed_in?
        get_subscriptions
        @history = true
        
        @page_title = "Your history"
        
        @feed_content = FeedContentRedirect.select("DISTINCT(feed_content_id)").where('user_id = ?', current_user.id).order('created_at DESC').page(params[:page]).per(30)
        
        respond_to do |format|
          format.html # show.html.erb
        end
      else
        redirect user_session_path, "You need to sign in first"
      end
    else
      redirect root_path, "User not found"
    end
  end
end



private


def redirect(path, error)
    respond_to do |format|
      format.html { redirect_to path, :notice => error }
    end
end
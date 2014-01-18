class ApplicationController < ActionController::Base
  protect_from_forgery
  
  layout :layouting
  
  helper_method :loader_type
  
  def compute_tags    
    @blacklist = ["the","and","to","for","a","this","of","with","an", "in", "at","by","is", "as", "on"].sort
    
    @tags = []
   
    if user_signed_in?
      @feed_content = FeedContent.select('title, feed_contents.created_at').joins('JOIN feeds on feed_contents.feed_id = feeds.id').joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").order('feed_contents.pub_date DESC').limit(100)
    else
      @feed_content = FeedContent.select('title, feed_contents.created_at').joins('JOIN feeds on feed_contents.feed_id = feeds.id').where('feeds.private IS NULL OR feeds.private = 0').order('feed_contents.pub_date DESC').limit(50)
    end
    @feed_content.each do |titles_db|
      if titles_db.title != nil
        titles = titles_db.title.split(" ")
        titles.each do |title|
          @tags << title.strip.gsub(/[^0-9a-z ]/i, '') unless @blacklist.include?(title.downcase)
        end
      end
    end
    
    @since = @feed_content.first.created_at
    
    @tags.sort!
    @counts = Hash.new(0)
    @tags2 = []
    
    @tags.each do |t|
      @tags2 << t.downcase
      @counts[t.downcase] += 1
    end
    
    @tags = @tags2
    @tags.uniq!
    @tags.shuffle!
  end

  def mobile_device?
    if session[:mobile_param]
      session[:mobile_param] == "1"
    else
      request.user_agent =~ /Mobile|webOS/
    end
  end
  
  def get_count_since_last_visit
      @count = FeedContent.select('count(*)').joins('JOIN feeds on feed_contents.feed_id = feeds.id').joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").where("feed_contents.created_at > '#{@user.last_visit ? @user.last_visit : @user.created_at}'").order('feed_contents.pub_date DESC')
  end
  
  def get_subscriptions
      get_count_since_last_visit
      @subscriptions = Feed.joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").joins("JOIN feed_categories ON feeds.feed_category_id = feed_categories.id").where("feeds.private = 0 OR feeds.private IS NULL OR (feeds.private = 1 AND feeds.user_id = #{current_user.id})").order('feed_categories.name, feeds.name')
  end
  
  def get_available_feeds
      @available_feeds = Feed.joins("JOIN feed_categories ON feeds.feed_category_id = feed_categories.id").where("feeds.private = 0 OR feeds.private IS NULL OR (feeds.private = 1 AND feeds.user_id = #{current_user.id})").order('feed_categories.name, feeds.name')
  end
  
  def update_last_visit
    @user = User.find_by_id(current_user.id)
    if @user.this_visit 
      if (@user.last_visit < 20.minutes.ago)
        @user.last_visit = @user.this_visit
      end
    else
      @user.last_visit = Time.now
    end

    
    @user.this_visit = Time.now
    @user.save
  end
  
  def loader_type
    mobile_device? ? 'loader' : 'modal_link'
  end

  def admin_check
        @admin = has_role?(current_user, :admin) if user_signed_in?
  end
  
  def verify_user
    admin_check
    :authenticate_user!
    unless user_signed_in?
      redirect_to user_session_path, :notice => "You need to sign in to view this page."
    else
      @user = User.find_by_id(current_user.id)
      redirect_to landing_index_path, :notice => "Your account will be verified shortly." unless current_user.roles.where(:name => ['Registered','Admin']).present?
    end
  end  


  def has_role?(current_user, role)
    return !!current_user.roles.find_by_name(role.to_s.camelize)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end
  
  def default_thumbnails(query = "", limit = "")
    if limit.blank?
      limit = 6
    end
    
    if @admin
      @photos = Photo.where("id > 0 #{query}").order("created_at DESC").page(params[:page]).per(limit)
    else 
      if current_user
        @photos = Photo.where("(user_id = #{current_user.id} OR private = 0) #{query}").order("created_at DESC").page(params[:page]).per(limit)
      else
        @photos = Photo.where("(private = 0) #{query}").order("created_at DESC").page(params[:page]).per(limit)
      end
    end
  end
  
  private

    def layouting
      if !params[:layout]
        return 'application'
      end
    end

end
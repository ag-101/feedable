class FeedsController < ApplicationController
  
  before_filter :verify_user

  require 'rubygems'
  require 'nokogiri'

  def index
    get_subscriptions   
    
    if params[:cat]
      @feed_category = FeedCategory.find_by_id(params[:cat])
      
      if @feed_category.id
        @this_feed = @feed_category
        @no_more = true
        @feed_content = FeedContent.joins('JOIN feeds on feed_contents.feed_id = feeds.id').joins('JOIN feed_categories ON feed_categories.id = feeds.feed_category_id').joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").where("feed_categories.id = #{ @feed_category.id }").order('feed_contents.pub_date DESC').page(params[:page]).per(30)
      end
    else
     # @no_pagination = true
      
  #    hide_old_sql = "feed_contents.created_at >= '#{ @user.last_visit }'" if @count.count > 0
      
      @feed_content = FeedContent.joins('JOIN feeds on feed_contents.feed_id = feeds.id').joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").order('feed_contents.pub_date DESC').page(params[:page]).per(30)

    end
    @page = params[:page] || 1
  end
  
  def trending
    get_subscriptions
    compute_tags
  end
  
  def progress_bar
    @updated_feeds = Feed.readonly(false).joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").where('feed_type = "twitter_timeline" OR `last_updated` = 0 OR `last_updated` IS NULL OR `updated_at` >= ?', 120.minutes.ago)
    
    updated_items = 0
    @updated_feeds.each do |feed|
      updated_items += feed.last_updated if feed.last_updated != nil
    end
    
   json = '{
        "updated_items": '+updated_items.to_s+',
        "updated_feeds": '+@updated_feeds.count.to_s+'
    }'
        
    respond_to do |format|
        #format.html { redirect_to feeds_path, :notice => ("#{count} new items" if count > 0) }
        format.json { render :json => json, :status => :ok }
    end
  end
  
  def show
    @this_feed = Feed.find_by_id(params[:id])
    get_subscriptions
    @feed_content = FeedContent.where('feed_id = ?', params[:id]).order('feed_contents.pub_date DESC').page(params[:page]).per(30)
    
    @page = params[:page] || 1
  end
  
  def set_display_setting
    if params[:feed_display_setting] == "grid" or params[:feed_display_setting] == "list" or params[:feed_display_setting] == "magazine"
        @user.feed_display_setting = params[:feed_display_setting]
        @user.save
    end
    render :nothing => true
  end
  
  def subscriptions
    get_subscriptions
    get_available_feeds
    @subscriptions_page = true
  end
  
  def find_twitter_id    
    doc = Nokogiri::XML(open("http://api.twitter.com/1/users/show.xml?screen_name=#{params[:username]}"))
    
    id = ActionController::Base.helpers.strip_tags((doc.xpath("//id").first).to_s)

    
    respond_to do |format|
        format.json { render :text => id, :status => :ok }
    end
  end

  
  def saved
    get_subscriptions
    @saved_items = true
    
    @page_title = "Saved items"
    
    @feed_content = FeedContentUser.where('user_id = ?', current_user.id).page(params[:page]).per(30)
    @page = params[:page] || 1
  end
   
  def parse_feeds
    require 'feedzirra'
    new_items = 0

    feeds_to_update = Feed.readonly(false).joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").where('`updated_at` < ?', 120.minutes.ago).limit(3)
 
    total_to_update = params[:total_to_update].to_i 
    total_to_update = Feed.joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").where('`updated_at` < ?', 120.minutes.ago).count if total_to_update <= 0

    already_parsed = params[:already_parsed].to_i
    feeds_to_update_count = 0

    feeds_to_update.each_with_index do |feed, index|  
      feeds_to_update_count = feeds_to_update_count + 1    
      if index < 3
        this_count = 0
        begin        
          Feedzirra::Feed.add_common_feed_entry_element(:enclosure, :value => :url, :as => :enclosure_href) if feed.feed_type == "podcast"   
          rss = Feedzirra::Feed.fetch_and_parse(feed.url, :timeout=>5)
  
          if rss != ""
            rss.entries.each do |item|  
              if item.published > 4.weeks.ago
                feed_content = FeedContent.new
                if feed.feed_type == "twitter_timeline"
                  twitter_contents = item.description.split(": ", 2)
                  feed_content.title = twitter_contents[0]
                  feed_content.description = twitter_contents[1]
                else
                  feed_content.title = item.title
                  feed_content.description =  ActionController::Base.helpers.sanitize(item.summary, :tags=>['img', 'p', 'br']) || ""
                  feed_content.description +=  ActionController::Base.helpers.sanitize(item.content, :tags=>['img', 'p', 'br']) if item.content
                end
                feed_content.pub_date = Time.parse(item.published.to_s) rescue Time.now
                
                if feed.feed_type == "podcast"
                   feed_content.url = item.enclosure_href rescue item.link
                else
                  feed_content.url = item.url
                end
                feed_content.feed_id = feed.id
      
                if feed_content.save
                  new_items = new_items + 1
                  this_count = this_count + 1
                end
              end 
            end
          end 
          
        rescue Exception => e
          puts "Skipping feed #{feed.name}"
          ActiveRecord::Base.connection.execute("UPDATE feeds SET image='error', last_updated = #{this_count}, updated_at = '#{  Time.now.utc.to_s(:db) }' WHERE id = #{feed.id}")
          this_count = this_count + 1
          next
        end
        
        already_parsed = already_parsed + 1
        ActiveRecord::Base.connection.execute("UPDATE feeds SET image='', last_updated = #{this_count}, updated_at = '#{  Time.now.utc.to_s(:db) }' WHERE id = #{feed.id}")
      end
    end
    
   already_parsed = already_parsed + 1 if already_parsed == params[:already_parsed].to_i
    
   json = '{
        "new_items": '+new_items.to_s+',
        "total_to_update": '+total_to_update.to_s+',
        "already_parsed": '+already_parsed.to_s+',
        "updated": "'+(feeds_to_update.map { |f| f.name }.join ';')+'"
    }'
    
    respond_to do |format|
        #format.html { redirect_to feeds_path, :notice => ("#{count} new items" if count > 0) }
        format.json { render :json => json, :status => :ok }
    end
  end
  
  def update_time
    update_last_visit
    render :nothing => true
  end
  
  def more
    
    @no_pagination = true
    @loading_more = true
    @user = User.find_by_id(current_user.id)
    
    get_count_since_last_visit

    
    @feed_content = FeedContent.joins('JOIN feeds on feed_contents.feed_id = feeds.id').joins("JOIN feed_users ON feed_users.feed_id = feeds.id AND feed_users.user_id = #{current_user.id}").order('feed_contents.pub_date DESC').page(params[:page]).per(30)
    @page = params[:page] || 1
    
    render :layout => false
  end
  
  # GET /feeds/new
  # GET /feeds/new.json
  def new
    admin_check
    
    @feed = Feed.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @feed }
    end
  end
  
  def create
    @feed = Feed.new(params[:feed])
    @feed.user_id = current_user.id

    respond_to do |format|
      if @feed.save
        format.html { redirect_to feeds_subscriptions_path, :notice => 'Feed was successfully created.' }
        format.json { render :json => @feed, :status => :created, :location => @feed }
      else
        format.html { render :action => "new" }
        format.json { render :json => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    if @admin
      @feed = Feed.find(params[:feed_id])
      @feed.destroy
    end

    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.json { head :no_content }
    end
  end  
  
  def subscribe
    admin_check

    @feed_user = FeedUser.where('feed_id = ? and user_id = ?', params[:feed_id], current_user.id)
    if @feed_user.count > 0
      @feed_user.each do |fu|
        ActiveRecord::Base.establish_connection
        ActiveRecord::Base.connection.execute("DELETE FROM `feed_users` WHERE feed_id = #{ fu.feed_id } AND user_id = #{ fu.user_id }")
      end
      
    else

      @subscription = FeedUser.new
      @feed = Feed.find_by_id(params[:feed_id])
      
      @subscription.user_id = current_user.id
      @subscription.feed_id = @feed.id
      
      @subscription.save
    
    end
    


    respond_to do |format|
    begin
      
          @feed = Feed.find_by_id(params[:feed_id])
          
      
          @subscription_message = "Subscribed"
          format.html { render :partial=>'feed' }

    
      rescue  => e
          @subscription_message = "There has been an error processing your subscription to this feed.\n\nPerhaps you are already subscribed?"
          format.html { render :partial=>'subscriptions', :status => :unprocessable_entity }
      end 
    end
  end
  
  def unsubscribe
    admin_check
    
    @feed_user = FeedUser.where('feed_id = ? and user_id = ?', params[:feed_id], current_user.id)
    if @feed_user.count > 0
      @feed_user.each do |fu|

        ActiveRecord::Base.establish_connection
        ActiveRecord::Base.connection.execute("DELETE FROM `feed_users` WHERE feed_id = #{ fu.feed_id } AND user_id = #{ fu.user_id }")
        @subscription_remove = true
      end
    end
    
    @feed = Feed.find_by_id(params[:feed_id])
    respond_to do |format|
    begin
      
      get_subscriptions
    
      if @subscription_remove == true
          @subscription_message = "Unsubscribed"
          format.html { render :partial=>'subscriptions' }
      else
          @subscription_message = "There was an error unsubscribing from this feed."
          format.html { render :partial=>'subscriptions', :status => :unprocessable_entity }
      end
    
      rescue  => e
          @subscription_message = "There has been an error unsubscribing from this feed.\n\nPerhaps you are not already subscribed?"
          format.html { render :partial=>'subscriptions', :status => :unprocessable_entity }
      end 
    end
  end
end

private


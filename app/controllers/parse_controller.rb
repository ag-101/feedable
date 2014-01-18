class ParseController < ApplicationController
  
  def parse_all_feeds
     delete_old
     require 'feedzirra'
     @feeds_to_update = Feed.readonly(false).select("DISTINCT(feeds.id), feeds.*").joins('JOIN `feed_users` ON feeds.id = feed_users.feed_id').where('`updated_at` < ?', 60.minutes.ago)
     
     feeds_to_update_count = 0
     new_items = 0
     @feeds_to_update.each_with_index do |feed, index|  
       feeds_to_update_count = feeds_to_update_count + 1    
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
                   feed_content.description =  ActionController::Base.helpers.sanitize(item.summary, :tags=>['img', 'p', 'br', 'embed']) || ""
                   feed_content.description +=  ActionController::Base.helpers.sanitize(item.content, :tags=>['img', 'p', 'br', 'embed']) if item.content
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
        
         ActiveRecord::Base.connection.execute("UPDATE feeds SET image='', last_updated = #{this_count}, updated_at = '#{  Time.now.utc.to_s(:db) }' WHERE id = #{feed.id}")
      end     
      
      @new_items = new_items
      render :layout => false
  end 
  
  private
  
  def delete_old
    @deleted = FeedContent.where("pub_date < '#{ 4.weeks.ago }'").where("feed_contents.id NOT IN (SELECT `feed_content_id` FROM (`feed_content_users`))").where("feed_contents.id NOT IN (SELECT `feed_content_id` FROM (`feed_content_redirects`))").destroy_all 
  end
  
end

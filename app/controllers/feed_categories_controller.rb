class FeedCategoriesController < ApplicationController
  
    before_filter :verify_user

  # GET /feed_categories/new
  # GET /feed_categories/new.json
  def new
    @feed_category = FeedCategory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @feed_category }
    end
  end

  def edit
  end
  
  def destroy
    if @admin
      @feed_category = FeedCategory.find(params[:feed_category_id])
      @feed_category.destroy
    end

    respond_to do |format|
      format.html { redirect_to feeds_path }
      format.json { head :no_content }
    end
  end    
  
  def create
    @feed_category = FeedCategory.new(params[:feed_category])
    @feed_category.user_id = current_user.id

    respond_to do |format|
      if @feed_category.save
        format.html { redirect_to feeds_path, :notice => 'Feed Category was successfully created.' }
        format.json { render :json => @feed_category, :status => :created, :location => @feed_category }
      else
        format.html { render :action => "new" }
        format.json { render :json => @feed_category.errors, :status => :unprocessable_entity }
      end
    end
  end
end

class Admin::AdminController < ApplicationController
  layout "application"
  before_filter :verify_admin

  def verify_admin
    :authenticate_user!
    unless user_signed_in?
      redirect_to user_session_path, :notice => "You need to sign in to view this page."
    else
      redirect_to root_path, :notice => "You don't have permission to view that page." unless current_user.roles.where(:name => ['Admin']).present?
    end
  end

  def current_ability
    @current_ability ||= AdminAbility.new(current_user)
  end
end
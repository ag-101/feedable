class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user
    if user.role? :admin
      can :manage, :all
    elsif user.role? :registered
      can :create, :all
      can :manage, Blog do |blog|
        blog.try(:user_id) == user
      end
    else
      can :read, :all
    end
  end
end
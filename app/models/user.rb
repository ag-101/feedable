class User < ActiveRecord::Base
  
    
    # Include default devise modules. Others available are:
    # :token_authenticatable, :confirmable,
    # :lockable, :timeoutable and :omniauthable, :recoverable
    devise :database_authenticatable, :registerable,
            :rememberable, :trackable, :validatable
  
    # Setup accessible (or protected) attributes for your model
    attr_accessible :role_ids, :username, :email, :password, :password_confirmation, :remember_me, :login
    attr_accessor :login
    
    has_many :feed_user
    has_many :feed, :through => :feed_user
    has_many :feed_content, :through => :feed_content_user
    
    has_and_belongs_to_many :roles
    has_many :photo


    def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
    end
  
    before_save :setup_role
  
  
    def role?(role)
        return !!self.roles.find_by_name(role.to_s.camelize)
    end
  
    # Default role is "Registered"
    def setup_role
      if self.role_ids.empty?     
        self.role_ids = [3] 
      end
    end
end


 


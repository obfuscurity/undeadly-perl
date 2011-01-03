class User < ActiveRecord::Base
  has_one :role
  validates_uniqueness_of :username, :email

  def self.create_unless_user_exists(attributes)
    username = User.find_by_username(attributes[:username])
    email = User.find_by_email(attributes[:email])
    if username or email
      return nil
    else
      User.create(attributes)
    end
  end

  def to_json
    super(:except => :password)
  end
end

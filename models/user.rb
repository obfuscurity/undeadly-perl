class User < ActiveRecord::Base
  has_one :role
  validates_uniqueness_of :username, :email

  def to_json
    super(:except => :password)
  end
end

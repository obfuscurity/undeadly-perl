class User < ActiveRecord::Base
  has_one :role, :foreign_key => 'role_id'
  validates_uniqueness_of :username, :email

  def to_json
    super(:except => :password)
  end
end

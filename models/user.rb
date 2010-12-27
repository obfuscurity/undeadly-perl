class User < ActiveRecord::Base
  has_one :role, :foreign_key => 'role_id'
end

class Comment < ActiveRecord::Base
  belongs_to :article
  has_one :user
end

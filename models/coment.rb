class Comment < ActiveRecord::Base
  belongs_to :article, :foreign_key => 'article_id'
  has_one :user, :foreign_key => 'user_id'
end

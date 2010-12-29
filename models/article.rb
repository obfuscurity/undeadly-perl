class Article < ActiveRecord::Base
  has_many :revisions
  has_one :topic
end

class Article < ActiveRecord::Base
  has_many :revisions, :foreign_key => 'revision_id'
  has_one :topic, :foreign_key => 'topic_id'
end

class CreateArticlesTable < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.references :revision
      t.references :topic
      t.string :status
    end
    execute <<-SQL
      ALTER TABLE articles
        ADD CONSTRAINT fk_articles_revisions
        FOREIGN KEY (revision_id)
        REFERENCES revisions(id)
      ALTER TABLE articles
        ADD CONSTRAINT fk_articles_topics
        FOREIGN KEY (topic_id)
        REFERENCES topics(id)
    SQL
  end

  def self.down
    drop_table :articles
  end
end

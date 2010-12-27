class CreateArticlesTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE articles(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         revision_id INTEGER,
         topic_id INTEGER,
         status VARCHAR(255),
         FOREIGN KEY(revision_id) REFERENCES revisions(id),
         FOREIGN KEY(topic_id) REFERENCES topics(id)
      );
    SQL
  end

  def self.down
    drop_table :articles
  end
end

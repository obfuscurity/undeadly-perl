class CreateArticlesTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE articles(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         revision_id INTEGER NOT NULL,
         topic_id INTEGER NOT NULL,
         status VARCHAR(255) NOT NULL,
         FOREIGN KEY(revision_id) REFERENCES revisions(id),
         FOREIGN KEY(topic_id) REFERENCES topics(id)
      );
    SQL
  end

  def self.down
    drop_table :articles
  end
end

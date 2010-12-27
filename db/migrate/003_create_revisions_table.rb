class CreateRevisionsTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE revisions(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         article_id INTEGER,
         user_id INTEGER,
         epoch INTEGER,
         title TEXT,
         dept TEXT,
         content TEXT,
         description TEXT,
         format VARCHAR(255),
         FOREIGN KEY(article_id) REFERENCES articles(id),
         FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
  end

  def self.down
    drop_table :revisions
  end
end

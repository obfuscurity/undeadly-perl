class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE comments(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         article_id INTEGER,
         user_id INTEGER,
         epoch INTEGER,
         title TEXT,
         content TEXT,
         score INTEGER,
         FOREIGN KEY(article_id) REFERENCES articles(id),
         FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
  end

  def self.down
    drop_table :comments
  end
end

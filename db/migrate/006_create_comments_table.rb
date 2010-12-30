class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE comments(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         article_id INTEGER NOT NULL,
         user_id INTEGER NOT NULL,
         epoch INTEGER NOT NULL,
         title TEXT NOT NULL,
         content TEXT NOT NULL,
         score INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY(article_id) REFERENCES articles(id),
         FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
  end

  def self.down
    drop_table :comments
  end
end

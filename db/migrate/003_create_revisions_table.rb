class CreateRevisionsTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE revisions(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         article_id INTEGER NOT NULL,
         user_id INTEGER NOT NULL,
         epoch INTEGER NOT NULL,
         title TEXT NOT NULL,
         dept TEXT NOT NULL,
         content TEXT NOT NULL,
         description TEXT NOT NULL,
         format VARCHAR(255) NOT NULL,
         FOREIGN KEY(article_id) REFERENCES articles(id),
         FOREIGN KEY(user_id) REFERENCES users(id)
      );
    SQL
  end

  def self.down
    drop_table :revisions
  end
end

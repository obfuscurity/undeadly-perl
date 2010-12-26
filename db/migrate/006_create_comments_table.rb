class CreateCommentsTable < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.references :article
      t.references :user
      t.integer :epoch
      t.string :title
      t.text :content
      t.integer :score
    end
    execute <<-SQL
      ALTER TABLE comments
        ADD CONSTRAINT fk_comments_articles
        FOREIGN KEY (article_id)
        REFERENCES articles(id)
      ALTER TABLE comments
        ADD CONSTRAINT fk_comments_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL
  end

  def self.down
    drop_table :comments
  end
end

class CreateRevisionsTable < ActiveRecord::Migration
  def self.up
    create_table :revisions do |t|
      t.references :article
      t.references :user
      t.integer :epoch
      t.string :title
      t.text :dept
      t.text :content
      t.text :description
      t.string :format
    end
    execute <<-SQL
      ALTER TABLE revisions
        ADD CONSTRAINT fk_revisions_articles
        FOREIGN KEY (article_id)
        REFERENCES articles(id)
      ALTER TABLE revisions
        ADD CONSTRAINT fk_revisions_users
        FOREIGN KEY (user_id)
        REFERENCES users(id)
    SQL
  end

  def self.down
    drop_table :revisions
  end
end

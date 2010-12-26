class CreateRolesTable < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name
      t.boolean :manage_admins, :default => false
      t.boolean :manage_editors, :default => false
      t.boolean :manage_users, :default => false
      t.boolean :edit_articles, :default => false
      t.boolean :delete_articles, :default => false
      t.boolean :create_articles, :default => false
      t.boolean :edit_comments, :default => false
      t.boolean :delete_comments, :default => false
      t.boolean :create_comments, :default => true
      t.boolean :read_articles, :default => true
    end
  end

  def self.down
    drop_table :roles
  end
end

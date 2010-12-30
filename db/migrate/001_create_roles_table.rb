class CreateRolesTable < ActiveRecord::Migration
  def self.up
    create_table :roles do |t|
      t.string :name, :null => false
      t.boolean :manage_admins, :null => false, :default => false
      t.boolean :manage_editors, :null => false, :default => false
      t.boolean :manage_users, :null => false, :default => false
      t.boolean :edit_articles, :null => false, :default => false
      t.boolean :delete_articles, :null => false, :default => false
      t.boolean :create_articles, :null => false, :default => false
      t.boolean :edit_comments, :null => false, :default => false
      t.boolean :delete_comments, :null => false, :default => false
      t.boolean :create_comments, :null => false, :default => true
      t.boolean :read_articles, :null => false, :default => true
    end
    add_index :roles, :name, :unique => true
  end

  def self.down
    drop_table :roles
  end
end

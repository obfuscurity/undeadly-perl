class CreateUsersTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE users(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         role_id INTEGER,
         username TEXT,
         firstname TEXT,
         lastname TEXT,
         email TEXT,
         url TEXT,
         tz TEXT,
         reputation INTEGER,
         FOREIGN KEY(role_id) REFERENCES roles(id)
      );
    SQL
  end

  def self.down
    drop_table :users
  end
end

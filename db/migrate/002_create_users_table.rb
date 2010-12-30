class CreateUsersTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE users(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         role_id INTEGER NOT NULL,
         username VARCHAR(255) NOT NULL,
         password VARCHAR(255) NOT NULL,
         firstname VARCHAR(255) NOT NULL,
         lastname VARCHAR(255) NOT NULL,
         email VARCHAR(255) NOT NULL,
         url TEXT NOT NULL,
         tz VARCHAR(255) NOT NULL,
         reputation INTEGER NOT NULL DEFAULT 0,
         FOREIGN KEY(role_id) REFERENCES roles(id)
      );
    SQL
  end

  def self.down
    drop_table :users
  end
end

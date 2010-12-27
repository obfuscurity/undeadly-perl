class CreateUsersTable < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      CREATE TABLE users(
         id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
         role_id INTEGER,
         username VARCHAR(255),
         password VARCHAR(255),
         firstname VARCHAR(255),
         lastname VARCHAR(255),
         email VARCHAR(255),
         url TEXT,
         tz VARCHAR(255),
         reputation INTEGER,
         FOREIGN KEY(role_id) REFERENCES roles(id)
      );
    SQL
  end

  def self.down
    drop_table :users
  end
end

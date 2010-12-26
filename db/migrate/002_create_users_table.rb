class CreateUsersTable < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.references :role
      t.string :username
      t.string :firstname
      t.string :lastname
      t.string :email
      t.string :url
      t.string :tz
      t.integer :reputation
    end
    execute <<-SQL
      ALTER TABLE users
        ADD CONSTRAINT fk_users_roles
        FOREIGN KEY (role_id)
        REFERENCES roles(id)
    SQL
  end

  def self.down
    drop_table :roles
  end
end

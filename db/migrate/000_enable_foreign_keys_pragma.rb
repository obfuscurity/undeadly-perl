class EnableForeignKeysPragma < ActiveRecord::Migration
  def self.up
    execute <<-SQL
      PRAGMA foreign_keys = ON
    SQL
  end

  def self.down
    execute <<-SQL
      PRAGMA foreign_keys = OFF
    SQL
  end
end

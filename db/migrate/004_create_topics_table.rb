class CreateTopicsTable < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.string :name, :null => false
      t.text :description, :null => false
      t.text :url, :null => false
    end
    add_index :topics, :name, :unique => true
  end

  def self.down
    drop_table :topics
  end
end

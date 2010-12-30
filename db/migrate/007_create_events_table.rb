class CreateEventsTable < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :type, :null => false
      t.text :message, :null => false
    end
  end

  def self.down
    drop_table :events
  end
end

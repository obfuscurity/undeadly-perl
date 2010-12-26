class CreateEventsTable < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :type
      t.text :message
    end
  end

  def self.down
    drop_table :events
  end
end

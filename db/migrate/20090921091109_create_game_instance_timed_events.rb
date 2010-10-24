class CreateGameInstanceTimedEvents < ActiveRecord::Migration
  def self.up
    create_table :timed_events do |t|
      t.references :game_instance
      t.datetime :time_trigger
      t.references :event, :polymorphic => true
      t.timestamps
    end
  end

  def self.down
    drop_table :timed_events
  end
end

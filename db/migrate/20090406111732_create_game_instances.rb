class CreateGameInstances < ActiveRecord::Migration
  def self.up
    create_table :game_instances do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :game_instances
  end
end

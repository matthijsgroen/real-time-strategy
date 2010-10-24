class AddGameTimeSupportToGameInstance < ActiveRecord::Migration
  def self.up
    add_column :game_instances, :game_start, :datetime
    add_column :game_instances, :game_paused_at, :datetime
    add_column :game_instances, :pause_time, :integer
  end

  def self.down
    remove_column :game_instances, :game_start
    remove_column :game_instances, :game_paused_at
    remove_column :game_instances, :pause_time
  end
end

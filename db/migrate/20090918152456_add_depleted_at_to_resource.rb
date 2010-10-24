class AddDepletedAtToResource < ActiveRecord::Migration
  def self.up
    add_column :resources, :depleted_at, :datetime
    add_column :resources, :game_instance_id, :integer
  end

  def self.down
    remove_column :resources, :depleted_at
    remove_column :resources, :game_instance_id
  end
end

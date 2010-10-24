class AddActionRadiusToAssetAndMovement < ActiveRecord::Migration
  def self.up
    add_column :assets, :action_radius, :float
    add_column :asset_movements, :departure_at, :datetime
    add_column :asset_movements, :game_instance_id, :integer
  end

  def self.down
    remove_column :asset_movements, :game_instance_id
    remove_column :asset_movements, :departure_at
    remove_column :assets, :action_radius
  end
end

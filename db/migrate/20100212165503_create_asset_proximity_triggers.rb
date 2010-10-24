class CreateAssetProximityTriggers < ActiveRecord::Migration
  def self.up
    create_table :asset_proximity_triggers do |t|
      t.references :alerted_asset
      t.references :asset_in_proximity
      t.references :movement
      t.references :game_instance
      t.datetime :in_range_at
      t.datetime :out_of_range_at

      t.timestamps
    end
  end

  def self.down
    drop_table :asset_proximity_triggers
  end
end

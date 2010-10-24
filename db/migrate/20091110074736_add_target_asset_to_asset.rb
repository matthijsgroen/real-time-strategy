class AddTargetAssetToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :target_asset_id, :integer
  end

  def self.down
    remove_column :assets, :target_asset_id
  end
end

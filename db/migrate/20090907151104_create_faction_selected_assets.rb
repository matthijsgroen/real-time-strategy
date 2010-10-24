class CreateFactionSelectedAssets < ActiveRecord::Migration
  def self.up
    create_table :faction_selected_assets, :id => false do |t|
      t.references :asset
      t.references :selection
    end
  end

  def self.down
    drop_table :faction_selected_assets
  end
end

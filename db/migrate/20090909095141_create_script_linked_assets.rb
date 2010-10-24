class CreateScriptLinkedAssets < ActiveRecord::Migration
  def self.up
    create_table :script_assets, :id => false do |t|
      t.references :script
      t.references :asset
    end
  end

  def self.down
    drop_table :script_assets
  end
end

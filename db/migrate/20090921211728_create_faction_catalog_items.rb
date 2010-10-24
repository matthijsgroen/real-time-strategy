class CreateFactionCatalogItems < ActiveRecord::Migration
  def self.up
    create_table :faction_catalog_items do |t|
      t.references :catalog
      t.string :item_type

      t.timestamps
    end
  end

  def self.down
    drop_table :faction_catalog_items
  end
end

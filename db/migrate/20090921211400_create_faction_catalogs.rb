class CreateFactionCatalogs < ActiveRecord::Migration
  def self.up
    create_table :faction_catalogs do |t|
      t.references :faction
      t.string :asset_type
      t.string :ability

      t.timestamps
    end
  end

  def self.down
    drop_table :faction_catalogs
  end
end

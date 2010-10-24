class CreateFactionSelections < ActiveRecord::Migration
  def self.up
    create_table :faction_selections do |t|
      t.references :faction
      t.integer :hotkey

      t.timestamps
    end
  end

  def self.down
    drop_table :faction_selections
  end
end

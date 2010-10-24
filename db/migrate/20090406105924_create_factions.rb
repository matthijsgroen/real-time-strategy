class CreateFactions < ActiveRecord::Migration
  def self.up
    create_table :factions do |t|
      t.references :game_instance
      t.string :name
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :factions
  end
end

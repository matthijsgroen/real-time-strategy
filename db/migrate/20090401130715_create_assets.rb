class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.references :game_instance
      t.references :faction
      t.string :type
      t.string :state
      t.references :part_of
      t.references :bound_to
      t.timestamps
    end
    add_column :assets, :location, :point, :srid => -1
    add_column :assets, :ground_space, :line_string, :srid => -1

    add_index :assets, :location, :spatial => true
    add_index :assets, :ground_space, :spatial => true
  end

  def self.down
    remove_index :assets, :ground_space
    remove_index :assets, :location
    drop_table :assets
  end
end

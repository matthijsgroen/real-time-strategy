class CreateAssetMovements < ActiveRecord::Migration
  def self.up
    create_table :asset_movements do |t|
      t.references :asset
      t.datetime :arrival_at

      t.timestamps
    end
    add_column :asset_movements, :path, :line_string, :srid => -1
    add_index :asset_movements, :path, :spatial => true
  end

  def self.down
    remove_index :asset_movements, :path
    drop_table :asset_movements
  end
end

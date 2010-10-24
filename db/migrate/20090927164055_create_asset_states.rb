class CreateAssetStates < ActiveRecord::Migration
  def self.up
    create_table :asset_states do |t|
      t.references :asset
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :asset_states
  end
end

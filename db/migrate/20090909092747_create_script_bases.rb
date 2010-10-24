class CreateScriptBases < ActiveRecord::Migration
  def self.up
    create_table :scripts do |t|
      t.references :game_instance
      t.references :faction
      t.string :type
      t.references :parent
      t.datetime :start_time
      t.datetime :end_time
      t.text :parameters
      t.integer :position
      t.references :initiated_by, :polymorphic => true

      t.timestamps
    end
  end

  def self.down
    drop_table :scripts
  end
end

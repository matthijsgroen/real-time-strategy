class CreateResourceGroups < ActiveRecord::Migration
  def self.up
    create_table :resource_groups do |t|
      t.references :owner, :polymorphic => true
      t.string :name
      t.integer :amount_limit
      t.datetime :depleted_at
      t.datetime :limit_reached_at
      t.integer :start_amount
      t.datetime :start_amount_at
      t.references :game_instance

      t.timestamps
    end
  end

  def self.down
    drop_table :resource_groups
  end
end

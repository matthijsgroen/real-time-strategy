class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.references :owner, :polymorphic => true
      t.string :name
      t.integer :start_amount
      t.datetime :start_amount_at
      t.integer :amount_hour
      t.integer :bulk_income
      t.integer :amount_limit
      t.datetime :limit_reached_at

      t.timestamps
    end
  end

  def self.down
    drop_table :resources
  end
end

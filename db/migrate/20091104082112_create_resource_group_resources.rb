class CreateResourceGroupResources < ActiveRecord::Migration

  def self.up
    create_table :resource_group_resources, :id => false do |t|
      t.references :resource
      t.references :resource_group
    end
  end

  def self.down
    drop_table :resource_group_resources
  end
end

class AddDeletedAtToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :deleted_at, :datetime
  end

  def self.down
    remove_column :assets, :deleted_at
  end
end

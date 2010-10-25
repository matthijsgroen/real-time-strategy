class Asset::State < ActiveRecord::Base
  set_table_name "asset_states"
  belongs_to :asset, :class_name => "Asset::Base"
end

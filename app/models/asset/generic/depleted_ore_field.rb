class Asset::Generic::DepletedOreField < Asset::Base
  internal_name :depleted_ore_field
  has_resource :metal, :amount => 0

end
class Asset::Generic::OreField < Asset::Base
	internal_name :ore_field
	has_resource :metal, :amount => 5000

	def metal_depleted(time)
		update_attribute :type, "Asset::Generic::DepletedOreField"
	end

end
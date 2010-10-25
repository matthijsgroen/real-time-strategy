class Script::Generic::ConstructAsset < Script::Base
  internal_name :construct_asset

  parameter :asset_type, :type => :asset_type, :required => true
  parameter :location, :type => :point, :alias => :at, :required => true
  parameter :constructed_asset, :type => :asset

  def roll
    scenario do |step|
      step.start_building_process
      step.construction_done
    end
  end

  private

  def start_building_process
    begin
      self.constructed_asset = asset_type.new :faction => faction, :game_instance => game_instance, :location => location
      constructed_asset.save!
    rescue ActiveRecord::RecordInvalid => e
      raise GameInstance::GameplayError.new(yard, "Can't build there", :no_build_space)
    end

    # TODO: Add here a 'construction resource' that must reach 100%
    constructed_asset.put_in_state :construction
    self.end_time = execution_time + 10 #self.constructed_asset.build_time
  end

  def construction_done
    #raise "#{self.parameters.inspect}"
    self.constructed_asset.remove_state :construction
    finish!
  end

end
class Asset::ProximityTrigger < ActiveRecord::Base
  set_table_name "asset_proximity_triggers"
  include Script::Support::Execution::InstanceMethods

  belongs_to :alerted_asset, :class_name => "Asset::Base"
  belongs_to :asset_in_proximity, :class_name => "Asset::Base"
  acts_as_timed_event :in_range_at, :out_of_range_at

  def in_range_at_notification
    #puts "#{I18n.l in_range_at, :format => "%H:%M:%S"} - proximity alert."
    execute_time = in_range_at
    update_attribute :in_range_at, nil
    alerted_asset.proximity_update_of(self, execute_time)
  end

  def out_of_range_at_notification
    #puts "#{I18n.l out_of_range_at, :format => "%H:%M:%S"} - leaving proximity alert."
    execute_time = out_of_range_at
    update_attribute :out_of_range_at, nil
    alerted_asset.proximity_update_of(self, execute_time)
  end

end

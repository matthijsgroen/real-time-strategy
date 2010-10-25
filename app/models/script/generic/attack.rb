class Script::Generic::Attack < Script::Base
  internal_name :attack

  parameter :asset, :type => :asset, :required => true
  parameter :target, :type => :asset, :required => true

  def roll
    scenario do |step|
      step.move_in_range
      step.start_fighting
    end
  end

  def asset_destroyed(time)
    puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - #{self.asset.inspect} was killed by #{self.target.inspect}"
    self.asset = nil
    finish!
  end

  def target_destroyed(time)
    puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - #{self.asset.inspect}: target (#{self.target.inspect}) destroyed"
    self.target = nil
    finish!
  end

  def target_proximity_update(time)
    puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - rechecking proximity for #{self.asset.inspect} and #{self.target.inspect}"
    asset.stop_fighting time
    finish!
  end

  alias :asset_proximity_update :target_proximity_update

  private

  def move_in_range
    #puts "=" * 30
    asset.stop_fighting execution_time
    asset.target_asset = target
    asset.save
    #puts "#{self.inspect}: moving in range of #{target.inspect} @ #{execution_time}"

    self.end_time      = execution_time
  end

  def start_fighting
    #puts "#{self.inspect}: fighting starts"
    self.end_time = nil
    finish! unless asset.engage target, execution_time
  end

end
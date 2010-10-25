module Extensions::GameTime

  def self.included base
    base.class_eval do
      # relations
      belongs_to :game_instance
    end
  end

  def execution_time
    $game_instance_times ||= {}
    $game_instance_times[self.game_instance_id] || Time.now
  end

end
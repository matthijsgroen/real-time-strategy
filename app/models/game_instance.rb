class GameInstance < ActiveRecord::Base

  has_many :factions
  has_many :assets, :class_name => "Asset::Base"
  has_many :scripts, :class_name => "Script::Base"
  has_many :resources
  has_many :timed_events, :class_name => "GameInstance::TimedEvent", :order => "time_trigger ASC"

  def update_world(time = Time.now.utc)
    return if paused?
    while finished_event = timed_events.first(:conditions => ["time_trigger <= ?", time])
      #puts "event_list: #{timed_events(true).inspect}"
      #raise "event finished"
      $game_instance_times          ||= {}
      $game_instance_times[self.id] = finished_event.time_trigger
      finished_event.handle_event
    end
    #puts "event_list: #{timed_events(true).inspect}"
  end

  def paused?
    !game_paused_at.nil?
  end

  def pause_game(time = Time.now)
    update_attribute :game_paused_at, time
  end

  def resume_game(time = Time.now.utc)
    return false unless paused?
    pause_duration = (time - game_paused_at)
    update_attributes :pause_time => (pause_time + pause_duration),
            :game_paused_at       => nil
    move_game_time :forward, pause_duration
  end

  def game_time
    paused? ? game_paused_at.utc : Time.now.utc
  end

  def skip_time_with(amount)
    move_game_time :backward, amount
  end

  protected
  include ActionView::Helpers::DateHelper

  def move_game_time(direction, duration)
    puts "-- Moving game time with #{distance_of_time_in_words(duration.seconds.from_now.utc, Time.now.utc)}"
    # http://dev.mysql.com/doc/refman/5.1/en/date-and-time-functions.html
    #SELECT something FROM tbl_name
    #		-> WHERE DATE_SUB(CURDATE(),INTERVAL 30 DAY) <= date_col;
    move_table_time direction, Script::Base, ["start_time", "end_time"], duration
    move_table_time direction, GameInstance::TimedEvent, ["time_trigger"], duration
    move_table_time direction, Resource, ["start_amount_at", "depleted_at", "limit_reached_at"], duration
    move_table_time direction, ResourceGroup, ["start_amount_at", "depleted_at", "limit_reached_at"], duration
    move_table_time direction, Asset::ProximityTrigger, ["in_range_at", "out_of_range_at"], duration
    move_table_time direction, Asset::Movement, ["departure_at", "arrival_at"], duration
  end

  def move_table_time(direction, table, columns, duration)
    function        = {:forward => "+", :backward => "-"}[direction]
    update_sequence = columns.collect { |column| "#{column} = #{column} #{function} INTERVAL '#{duration} seconds'" }
    table.update_all update_sequence * ", ", ["game_instance_id = ?", self.id]
  end

end

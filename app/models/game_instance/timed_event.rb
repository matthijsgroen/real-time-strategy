class GameInstance::TimedEvent < ActiveRecord::Base
	set_table_name "timed_events"
	belongs_to :game_instance
	belongs_to :event, :polymorphic => true

	def handle_event
		#puts "handling #{event.class.name} #{self.id}"
		destroy
		event.handle_timed_event(self.time_trigger)
	end

	def inspect
		t = (time_trigger || game_instance.game_time) - game_instance.game_time
		time = " @ [#{t.round >= 0 ? "+" : "-"}#{((t * -1) / 60.0).round}:#{"%02d" % (t.round % 60)}]" if time_trigger
		#"trigger: #{event.inspect}#{time}"
	end

end

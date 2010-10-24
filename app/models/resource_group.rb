class ResourceGroup < ActiveRecord::Base

	has_and_belongs_to_many :resources,
													:join_table => "resource_group_resources",
													:class_name => "Resource",
													:foreign_key => "resource_group_id",
													:association_foreign_key => "resource_id",
													:after_add => :add_resource,
													:after_remove => :remove_resource
	belongs_to :owner, :polymorphic => true
	acts_as_timed_event :limit_reached_at
	belongs_to :game_instance

	def limit_reached_at_notification
		#puts "r- limit_reached_notification for #{owner.inspect} @ #{limit_reached_at}"
		unless owner
			#puts "r- No owner to notify to"
			return
		end
		unless limit_reached_at and full?(limit_reached_at)
			#puts "r- Limit not yet reached: #{amount(limit_reached_at)} vs. #{amount_limit}"
			return
		end

		owner.send "#{name}_full", limit_reached_at if owner.respond_to? "#{name}_full"
		owner.resource_group_full(name.to_sym, limit_reached_at) if owner.respond_to? :resource_group_full
		owner.resource_group_notification(name.to_sym, :full, limit_reached_at) if owner.respond_to? :resource_group_notification
	end

	def full?(time = Time.new.utc)
		return false unless amount_limit
		amount(time) >= amount_limit
	end

	def amount(time = Time.now.utc)
  	return [resources.collect { |r| r.amount(time) }.sum, amount_limit].min
	end

	def inspect
		"#{name} #{amount}"
	end

	private

	#
	# 0:00 x1 starts shooting with 1.67 dmg/s
	# 0:02 x2 starts shooting with 1.67 dmg/s
	#
	#
	#

	def calculate_timespan life_points, damage_sources, time_limit = nil
		damage_sec = damage_sources.map { |s| s[:multiplier] * s[:damage_sec] }.sum
		return time_limit if damage_sec.zero?
#		puts "#{self.owner.inspect}: getting average damage per second: #{damage_sec}"
		est_time = life_points / damage_sec
#		puts "est-time: #{est_time} seconds for life: #{life_points}"
		return time_limit if time_limit and est_time > time_limit

#		damage_sources.map do |s|
#			(est_time * s[:damage_sec] * s[:multiplier]) % s[:burst]
#		end

		damage_rest = damage_sources.collect { |s| (est_time * s[:damage_sec] * s[:multiplier]) % s[:burst] }.sum
		return est_time if damage_rest.zero?
#		puts "rest damage: #{damage_rest}"

		max_burst_time = damage_sources.pop
		next_blow = ((est_time.to_f / max_burst_time[:burst].to_f).ceil * max_burst_time[:burst]) - est_time
		result = est_time + calculate_timespan(damage_rest, damage_sources, next_blow)
		#puts "time-result: #{result} seconds for life: #{life_points}"
		result
	end

	def add_resource(record)
		sources = accumulate_damage_sources
		self.start_amount_at = resources.sort { |a, b| a.start_amount_at <=> b.start_amount_at }.last.start_amount_at
		self.start_amount = resources.collect { |s| s.amount self.start_amount_at }.sum

		est = calculate_timespan amount_limit, sources

		self.limit_reached_at = est ? start_amount_at + est : nil	
		#puts "r- destruction of #{owner.inspect} in #{est} seconds"
		save!
	end

	def remove_resource(record)
		# TODO: Implement this
	end

	def accumulate_damage_sources
		resources.map do |resource|
			{
				:damage_hour => resource.amount_hour,
				:damage_sec => resource.amount_hour.to_f / 1.hour,
				:burst => resource.bulk_income || 1.0,
				:burst_sec => resource.bulk_duration,
				:multiplier => 1.0,
				:owner => resource.owner
			}
		end.sort { |a, b| b[:burst] <=> a[:burst] }
	end

end

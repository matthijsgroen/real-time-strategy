class Resource < ActiveRecord::Base

	belongs_to :owner, :polymorphic => true
	before_save :update_limit_reached, :update_depleted_at
	belongs_to :game_instance
	acts_as_timed_event :depleted_at, :limit_reached_at
	has_and_belongs_to_many :resource_groups,
													:join_table => "resource_group_resources",
													:class_name => "ResourceGroup",
													:foreign_key => "resource_id",
													:association_foreign_key => "resource_group_id"

	def disconnect_from_groups
		resource_groups.each { |group| group.resources.delete self }
	end

	def amount(time = Time.now.utc)
  	return [start_amount, amount_limit].compact.min if amount_hour.nil? or amount_hour.zero? or start_amount_at.nil?
    seconds = time - start_amount_at
    extra_amount = (amount_hour.to_f / 1.hour) * seconds
    extra_amount -= extra_amount % bulk_income unless bulk_income.nil? or bulk_income.zero?

    current_amount = (extra_amount + start_amount).floor
    [[current_amount, amount_limit].compact.min, 0].max
	end

	def inspect
		"#{amount} #{name}"
	end

	def bulk_duration
		(bulk_income || 1) / (amount_hour.to_f / 1.hour)
	end

	def duration_for_amount(need_amount, start = Time.now.utc)
    return 0 if amount(start) >= need_amount and amount_hour and amount_hour >= 0
    return 0 if amount(start) <= need_amount and amount_hour and amount_hour < 0
    return nil if amount_hour.zero?
		#return 0 if amount_limit and need_amount > amount_limit
		#return nil if need_amount < 0

    remaining = (need_amount - self.start_amount).abs
    remaining += bulk_income - (remaining % bulk_income) unless bulk_income.nil? or bulk_income.zero?

    remaining / (amount_hour.abs.to_f / 1.hour)
  end

	def increase(element, amount, time=Time.now.utc)
		case element
			when :amount then
				change element, amount(time) + amount, time
			when :production then
				change element, ((self.amount_hour || 0).to_f / 1.hour) + amount, time
			when :limit then
				change element, (self.amount_limit || 0) + amount, time
		end
	end

	def decrease(element, amount, time=Time.now.utc)
		case element
			when :amount then begin
				change element, amount(time) - amount, time
			end
			when :production then begin
				change element, ((self.amount_hour || 0).to_f / 1.hour) - amount, time
			end
			when :limit then begin
				change element, (self.amount_limit || 0) - amount, time
			end
		end
	end

	def change(element, new_value, time=Time.now.utc)
		amount_now = amount(time)
		case element
			when :amount then begin
				raise "Negative amounts not allowed" if new_value < 0
				self.start_amount = new_value
			end
			when :production then begin
				self.amount_hour = (new_value * 1.hour).round
			end
			when :limit then begin
				self.amount_limit = new_value
			end
		end
		self.start_amount = amount_now unless element == :amount
		self.start_amount_at = time

		save
		#raise "#{name} depleted #{depleted_at} max at #{limit_reached_at}" if owner.is_a? Asset::Terran::Unit::OreHarvester and amount_hour < 0
	end

	def full?(time = Time.new.utc)
		return false unless amount_limit
		amount(time) >= amount_limit
	end

	def depleted?(time = Time.new.utc)
		amount(time).zero?
	end

	def depleted_at_notification
		return unless owner
		return unless depleted_at and depleted?(depleted_at)

		owner.send("#{name}_depleted", depleted_at) if owner.respond_to? "#{name}_depleted"
		owner.resource_depleted(name.to_sym, depleted_at) if owner.respond_to? :resource_depleted
		owner.resource_notification(name.to_sym, :depleted, depleted_at) if owner.respond_to? :resource_notification
	end

	def limit_reached_at_notification
		return unless owner
		return unless limit_reached_at and full?(limit_reached_at)

		owner.send "#{name}_full", limit_reached_at if owner.respond_to? "#{name}_full"
		owner.resource_full(name.to_sym, limit_reached_at) if owner.respond_to? :resource_full
		owner.resource_notification(name.to_sym, :full, limit_reached_at) if owner.respond_to? :resource_notification
	end

	private

	def update_limit_reached
		self.limit_reached_at = nil
		if amount_limit and start_amount < amount_limit and amount_hour and amount_hour > 0
			duration = duration_for_amount(amount_limit, self.start_amount_at)
			self.limit_reached_at = self.start_amount_at + duration if duration > 0 
		end
	end

	def update_depleted_at
		self.depleted_at = nil
		if amount_hour and amount_hour < 0 and start_amount > 0
			duration = duration_for_amount(0, self.start_amount_at)
			self.depleted_at = self.start_amount_at + duration if duration > 0 
		end
	end

end

module Asset::Support::Combat

  module InstanceMethods

    def engage_near_hostiles
      return false unless has_weapons?

      possible_targets = game_instance.assets.hostile(faction).closest_at(location, sight)
      #puts "hostiles nearby: #{possible_targets.collect(&:inspect).to_sentence} - @ #{I18n.l execution_time}"
      possible_targets = possible_targets.select { |possible_target| can_engage? possible_target }

      possible_targets.sort! { |a, b| a.location.euclidian_distance(location) <=>
              b.location.euclidian_distance(location) }

      #puts "engageable hostiles nearby: #{possible_targets.collect(&:inspect).to_sentence} - @ #{I18n.l execution_time}"
      target = possible_targets.first
      return false unless target and target.location.euclidian_distance(location) < sight
      #puts "checking for hostiles nearby... found: #{target.inspect}"
      return false unless target


      attack :target => target, :start_time => execution_time
      return true
    end

    def has_weapons?
      !(self.class.weapons || []).empty?
    end

    def weapons
      @weapons ||= self.class.weapons.collect do |weapon|
        weapon_instance = ::Asset::Weapon.new :name => weapon[:name], :amount_hour => weapon[:damage] * 1.hour,
                :bulk_income => weapon[:burst] ?
                        weapon[:burst] * weapon[:damage] : nil
        weapon_instance.targets = weapon[:targets]
        weapon_instance.range = weapon[:range]
        weapon_instance
      end
    end

    def damage_pool_full(time)
      puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - #{self.inspect}: Aaaargh!"
      die(time)
    end

    def die(time = Time.now.utc)
      update_attribute :deleted_at, time
      self.scripts.each { |s| s.asset_notification(self, :destroyed, time) }
      destroy!
    end

    def health
      return self.hitpoints unless self.damage_pool
      self.hitpoints - self.damage_pool.amount(execution_time)
    end

    def add_damage_from weapon, time = Time.now.utc
      #puts "a-#{self.id} receiving incoming damage from #{weapon.name}"
      #puts "a-#{self.id} no damage pool, creating one." unless damage_pool
      self.damage_pool = ResourceGroup.create! :owner => self,
              :start_amount => 0,
              :amount_limit => self.hitpoints,
              :name => "damage_pool",
              :game_instance_id => self.game_instance_id,
              :start_amount_at => time unless damage_pool
      self.damage_pool.resources << weapon
    end

    def stop_fighting time = Time.now.utc
      self.class.weapons.each do |weapon|
        w = resources.find_by_name weapon[:name].to_s
        w.disconnect_from_groups
        # TODO: disconnect from damage group if connected
        w.update_attributes :amount_hour => 0, :bulk_income => 0, :limit_reached_at => nil, :depleted_at => nil if w
      end
    end

    def respond_to_with_weapons? method_name, include_private_methods = false
      result = respond_to_without_weapons? method_name, include_private_methods
      if !result and method_name.to_s =~ /^fire_([_a-zA-Z]\w*)_at$/
        self.class.weapons.each { |weapon| return true if weapon[:name].to_s == $1 }
      end
      result
    end

    def method_missing_with_weapons method_name, *args
      if respond_to_without_weapons? method_name
        method_missing_without_weapons method_name, *args
      elsif method_name.to_s =~ /^fire_([_a-zA-Z]\w*)_at$/
        fire_weapon_at($1, *args)
      else
        method_missing_without_weapons method_name, *args
      end
    end

    def engage target, time = Time.now.utc
      return false unless weapon = select_weapon_for(target)
      fire_weapon_at weapon, target, time
    end

    def select_weapon_for target
      result = self.class.weapons.find do |weapon|
        #puts "testing weapon-#{weapon[:name]}[#{weapon[:targets].to_sentence}] for target-#{target.class.internal_name}[#{target.classifications.to_sentence}]"
        target.meets_classifications? weapon[:targets]
      end
    end

    def can_engage? target
      select_weapon_for(target) ? true : false
    end

    private

    def fire_weapon_at selected_weapon, target, time = Time.now.utc
      weapon_stats = case selected_weapon
                       when Symbol, String then
                         self.class.weapons.find { |weapon| weapon[:name].to_s == selected_weapon.to_s }
                       when Hash then
                         selected_weapon
                     end
      puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - #{self.inspect} firing #{weapon_stats[:name]} at #{target.inspect}"
      #puts "a-#{self.id} listening scripts: #{scripts.inspect}"

      weapon = resources.find_by_name weapon_stats[:name].to_s
      raise ActiveRecord::RecordNotFound, "selected weapon \"#{weapon_stats[:name]}\" not found." unless weapon
      attributes = {
              :amount_hour => weapon_stats[:damage] * 1.hour,
              :bulk_income => weapon_stats[:burst] ? 1.0 + (weapon_stats[:burst].to_f * weapon_stats[:damage]).floor : 1.0,
              :start_amount => 0, :start_amount_at => time
      }
      weapon.update_attributes attributes
      target.add_damage_from weapon, time
      return true
    end
  end

  module ClassMethods

    # adds a weapon to this asset's disposal.
    # valid options are: :damage, :burst, :targets, :range
    def weapon(name, options = {})
      options.assert_valid_keys :damage, :burst, :targets, :range
      options[:targets] ||= []
      options[:targets] = [options[:targets]] unless options[:targets].is_a? Array

      #puts "#{self.name} - #{self.metaclass}"

      @weapons ||= []
      @weapons << {:name => name}.reverse_merge!(options)

      has_resource name, {}
    end

    attr_reader :weapons

  end

  def self.included base
    base.extend ClassMethods
    base.class_eval do
      include Asset::Support::Combat::InstanceMethods

      alias_method_chain :respond_to?, :weapons
      alias_method_chain :method_missing, :weapons

      # relations
      belongs_to :target_asset, :class_name => "Asset::Base"
      has_one :damage_pool, :class_name => "ResourceGroup", :as => :owner, :dependent => :destroy
    end
  end

end

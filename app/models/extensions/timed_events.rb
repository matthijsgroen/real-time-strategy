module Extensions::TimedEvents

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods
    def acts_as_timed_event(*fields)
      options                   = fields.extract_options!
      unless timed_event? # don't let AR call this twice
        cattr_accessor :defined_event_fields, :event_field_options
        has_one :timed_event, :class_name => "GameInstance::TimedEvent", :as => :event, :dependent => :destroy
        after_save :update_timed_event
      end
      include InstanceMethods
      self.defined_event_fields ||= []
      self.defined_event_fields += fields
      self.event_field_options  ||= {}
      fields.each { |f| event_field_options[f] = options }
    end

    def timed_event?
      self.included_modules.include?(InstanceMethods)
    end
  end

  module InstanceMethods

    def update_timed_event
      field_values = self.class.defined_event_fields.flatten.collect do |field|
        options = self.class.event_field_options[field] || {}
        execute = true
        execute = false if options[:if] and not send options[:if]
        execute = false if options[:unless] and send options[:unless]
        execute ? self.send(field) : nil
      end
      closest      = field_values.compact.min
      if self.timed_event and closest
        #raise "huh for #{self.inspect}"
        self.timed_event.update_attribute :time_trigger, closest unless self.timed_event.time_trigger == closest
      elsif closest and self.timed_event.nil?
        self.timed_event = GameInstance::TimedEvent.create! :event => self, :time_trigger => closest,
                :game_instance_id                                  => self.game_instance_id
        #puts "created #{self.timed_event.id}: #{timed_event.inspect}"
      elsif closest.nil? and self.timed_event
        self.timed_event.destroy
      end
    end

    def handle_timed_event(time)
      field_values = {}
      self.class.defined_event_fields.flatten.each do |field|
        options = self.class.event_field_options[field] || {}
        execute = true
        execute = false if options[:if] and not send options[:if]
        execute = false if options[:unless] and send options[:unless]
        field_values[field] = self.send field if execute
      end
      field_values.each do |field, value|
        #puts "handling: #{field}_notification of #{self.inspect} (#{value} == #{time})"
        if value == time
          send "#{field}_notification"
          return
        end
      end
    end

  end
end
module Extensions::Resources

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods

    # Declares that the ActiveRecord::Base object has a resource
    # eg: <tt>has_resource :oil, :limit => 1000</tt>
    #
    # These resources are initialized upon the creation of the object in the database
    # When the record is destroyed the attached resources are destroyed as well.
    #
    # The following options are allowed:
    # - :limit -- The max amount this resource can hold
    # - :amount -- The start amount of this resource
    # - :bulk -- The threshold of amount before it is added to the amount. Eg. If you want resources to be adde per 8, use <tt>:bulk => 8</tt>
    # - :income -- The amount of resources gained per second. This can also be a negative amount.
    #
    # Examples:
    # - <tt>has_resource :poison, :amount => 1000, :income => -20.0 / 1.minute</tt>
    # - <tt>has_resource :gold, :amount => 0, :income => 1000.0 / 1.hour</tt>
    #
    # For information about resource events, see Resource
    def has_resource(name, options)
      unless resources? # don't let AR call this twice
        cattr_accessor :defined_resources
        has_many :resources, :class_name => "Resource", :as => :owner, :dependent => :destroy
        after_create :initialize_resources
      end
      include InstanceMethods

      self.defined_resources ||= []
      self.defined_resources << [name, options]
      has_one name, :class_name => "Resource", :as => :owner, :conditions => {:name => name.to_s}
    end

    # Checks of the recieving object has resources attached.
    def resources?
      self.included_modules.include?(InstanceMethods)
    end
  end

  module InstanceMethods # :nodoc:
    def initialize_resources

      (self.class.defined_resources || []).each do |name, options|
        #puts "initializing #{name}"
        res                  = Resource.new(:name => name.to_s, :owner => self)
        res.game_instance_id = self.game_instance_id
        res.amount_limit     = options[:limit]
        res.start_amount     = options[:amount] || 0
        res.start_amount_at  = Time.now
        res.bulk_income      = options[:bulk]
        res.amount_hour      = ((options[:income] || 0) * 1.hour).round
        res.save!
      end
    end
  end

end
# = Abilities
# Abilities provide interactivity to Assets.
# The main function to use when declaring an asset is the "has_ability" method on Class level.
# This function creates a bridge between the Asset and the Script executing the action.
#
# == Callbacks
# there are 2 callbacks to use: before_ability and after_ability
#
module Asset::Support::Abilities

  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
    base.class_eval do
      include Asset::Support::Abilities::InstanceMethods
      base.send :include, ActiveSupport::Callbacks
      base.define_callbacks :ability
    end
  end

  module ClassMethods

    def has_ability(*args)
      options = args.extract_options!
      @abilities ||= []
      args.each do |ability|
        @abilities << ability
        define_ability_method(ability, options)
      end
    end

    def has_catalog_ability(name, catalog, options = {})
      method_name = options[:as] || name
      @abilities ||= []
      @abilities << method_name
      @catalog_abilities ||= []
      @catalog_abilities << method_name
      define_catalog_ability_method(name, catalog, options)
    end

    def after_ability(method, options = {})
      set_callback :ability, :after, method, options
    end

    def before_ability(method, options = {})
      set_callback :ability, :before, method, options
    end

    attr_reader :abilities
    attr_reader :catalog_abilities
    attr_accessor :ability_catalogs

    def generated_abilities?
      !generated_abilities.empty?
    end

    def generated_abilities
      @generated_abilities ||= Set.new
    end

    private

    RESERVED_ABILITY_NAMES = [:create, :update, :save]

    def define_ability_method(name, options={})
      method_name = options[:as] || name
      raise "Name '#{method_name}' is reserved" if RESERVED_ABILITY_NAMES.include? method_name
      ability_code = <<-EOC
				return false if run_callbacks(:before_ability) == false
				script = Script::Manager[:#{name}]
				options = args.extract_options!
				options[:asset] = self
				options[:initiated_by] = self
				script.execute(*(args << options))
      EOC
      evaluate_ability_method method_name, "def #{method_name}(*args); #{ability_code}; end"
    end

    def define_catalog_ability_method(name, catalog, options={})
      method_name = options[:as] || name
      raise "Name '#{method_name}' is reserved" if RESERVED_ABILITY_NAMES.include? method_name
      self.ability_catalogs ||= {}
      self.ability_catalogs[method_name] = catalog
      ability_code = <<-EOC
				return false if run_callbacks(:before_ability) == false
				raise "Item: #\{item} not available" unless #{method_name}_catalog.include? item
				script = Script::Manager[:#{name}]
				options = args.extract_options!
				options[:asset] = self
				options[:item] = Asset::Manager[item]
				options[:initiated_by] = self
				script.execute(*(args << options))
      EOC
      evaluate_ability_method method_name, "def #{method_name}(item, *args); #{ability_code}; end"

      catalog_code = <<-EOC
				return @items if @items
				return [] unless faction
				catalog = faction.catalogs.find_by_asset_type_and_ability(self.class.internal_name.to_s, "#{method_name}")
				@items = catalog.items.collect { |item| item.item_type.to_sym } if catalog
				@items ||= []
      EOC
      evaluate_ability_method "#{method_name}_catalog", "def #{method_name}_catalog; #{catalog_code}; end"
    end

    def evaluate_ability_method(attr_name, method_definition, method_name=attr_name)
      generated_abilities << method_name

      begin
        class_eval(method_definition, __FILE__, __LINE__)
      rescue SyntaxError => err
        generated_abilities.delete(method_name)
        puts err.message
        if logger
          logger.warn "Exception occurred during ability method compilation."
          logger.warn "Maybe #{method_name} is not a valid Ruby identifier?"
          logger.warn err.message
        end
      end
    end
  end

  module InstanceMethods

    def abilities
      self.class.abilities
    end

    attr_reader :last_ability, :proximity_trigger

    def script_finished(script)
      @last_ability = script
      run_callbacks(:after_ability)
    end

    def proximity_update_of(trigger, time = Time.now.uts)
      @proximity_trigger = trigger
      #puts "[#{self.inspect}]: actions in progress: #{initiated_scripts.count}"
      if initiated_scripts.empty?
        run_callbacks(:after_ability)
      else
        # TODO: Rechecking current actions on proximity
        scripts.each do |script|
          script.asset_notification(self, :proximity_update, time)
        end
      end
    end

    def resource_notification resource, full_or_depleted, time = Time.now.uts
      scripts.each do |script|
        script.resource_notification(self, resource, full_or_depleted, time)
      end
    end

    def resource_group_notification resource_group, full_or_depleted, time = Time.now.uts
      #puts "a- informing #{scripts.length} scripts of notification: #{self.inspect}"
      scripts.each do |script|
        #puts "a- script: #{script.inspect}"
        script.resource_group_notification(self, resource_group, full_or_depleted, time)
      end
    end

    private

    def initiated_scripts
      Script::Base.find_all_by_initiated_by_id_and_initiated_by_type(
              self.id, self.class.name)
    end

  end

end
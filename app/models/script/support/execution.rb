module Script::Support::Execution

  module InstanceMethods

    attr_accessor :execution_time, :finished_subscript

    def load_settings_from(settings = {})
      self.parameters       ||= {}
      self.parent_id = settings[:parent].id if settings[:parent]
      self.parent_id        ||= settings[:parent_id]

      if settings[:parent] or settings[:parent_id]
        parent                = settings[:parent] || Script::Base.find(settings[:parent_id])
        self.faction_id       = parent.faction_id
        self.game_instance_id = parent.game_instance_id
      end

      if settings[:asset] or settings[:asset_id]
        asset                 = settings[:asset] || Asset::Base.find(settings[:asset_id].to_i)
        self.faction_id       = asset.faction_id
        self.game_instance_id = asset.game_instance_id
      end

      self.faction_id = settings[:faction].id if settings[:faction]
      self.faction_id = settings[:faction_id] if settings[:faction_id]

      self.game_instance_id ||= settings[:game_instance_id]
      self.game_instance_id = settings[:game_instance].id if settings[:game_instance]
      if not self.game_instance_id and self.faction_id
        faction               = settings[:faction] || Faction.find(self.faction_id)
        self.game_instance_id = faction.game_instance_id
      end
      self.start_time       = settings[:start_time] || Time.now.utc
      self.execution_time   = self.start_time
      self.end_time         ||= settings[:end_time]
    end

    def start
      @override_position = 0
      roll
      @override_position = nil
      save! unless frozen? #if script.end_time and script.end_time > script.game_time
    end

    def finish_step
      self.execution_time = self.end_time || game_time
      puts "#{I18n.l execution_time, :format => "%H:%M:%S"} - finished step #{self.inspect}"
      advance
      roll
      save! unless frozen? #if script.end_time and script.end_time > script.game_time
    end

    def finish!
      if parent
        parent.subscript_finished(self)
        destroy
      else
        destroy
        initiated_by.script_finished(self) if initiated_by and initiated_by.respond_to? :script_finished
      end
    end

    def abort!
      parent.abort! if parent
      destroy
    end

    protected

    def execute_subscript(name, *args)
      self.save if self.new_record?
      options              = args.extract_options!
      options[:parent]     = self
      options[:start_time] ||= execution_time
      subscript            = Script::Manager[name].execute *(args << options)
      #subscript.finish_step if subscript.end_time and subscript.end_time < game_time
      subscript
    end

    def execute_subscript_with_advancement(name, *args)
      advance
      execute_subscript_without_advancement(name, *args)
    end

    alias_method_chain :execute_subscript, :advancement

    def subscript_finished(subscript)
      self.finished_subscript = subscript
      self.execution_time     = subscript.end_time
      roll
      save! unless frozen?
    end

    def scenario
      raise "Block required" unless block_given?
      scenario = Script::Scenario.new(self, @override_position || self.position)
      begin
        yield scenario
      rescue GameInstance::GameplayError => e
        faction.messages << Faction::Message.new(:message => e.message)
        finish!
      end
      finish! unless scenario.executed?
    end

    def advance
      @override_position = nil
      update_attribute :position, self.position + 1
    end

    def loop_step
      @override_position = nil
      update_attribute :position, self.position - 1
    end

    def game_time
      game_instance.game_time
    end

    def script_already_running?
      new_record?
    end

    def roll
      # needs to be implemented at the script
      scenario do |step|
        # place scenario steps here
      end
    end

    def end_time_notification
      finish_step
    end

    def start_time_notification
      self.execution_time = self.start_time
      start if end_time.nil? and position.zero?
    end

    def new_script?
      end_time.nil? and position.zero?
    end

  end

  module ClassMethods

    def internal_name(name_symbol = nil)
      if name_symbol
        @internal_name = name_symbol
        Script::Manager.register_type(self, name_symbol)
      end
      @internal_name
    end

    def execute(*args)
      options         = args.extract_options!

      if options[:initiated_by]
        script = find_or_initialize_by_initiated_by_id_and_initiated_by_type(
                options[:initiated_by].id, options[:initiated_by].class.name)
      else
        script = self.new
      end
      #puts options.inspect
      script.position = 0
      script.load_settings_from options
      script.load_parameters_from options
      script.start
      script
    end

  end

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include Script::Support::Execution::InstanceMethods
      acts_as_timed_event :end_time
      #acts_as_timed_event :start_time, :if => :new_script?
    end
  end

end
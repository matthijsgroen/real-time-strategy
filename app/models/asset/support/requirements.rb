module Asset::Support::Requirements

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include Asset::Support::Requirements::InstanceMethods
      include GameInstance::Positioning

      validate :validate_build_requirements, :on => :create
    end
  end

  module ClassMethods

    def build_requirements
      @requirements ||= []
    end

    def spawn(*args)
      item = new(*args)
      item.save_without_build_requirements
      item
    end

    def build_requires_presence_of(*args)
      options = args.extract_options!
      @requirements ||= []
      @requirements << {
              :validates => :presence_of,
              :class_symbols => args,
              :options => options
      }
    end

  end

  module InstanceMethods

    def save_without_build_requirements
      @skip_build_requirements = true
      save.tap do |state|
        @skip_build_requirements = false
      end
    end

    protected

    def validate_build_requirements
      unless @skip_build_requirements
        errors.add(:base, "Asset must be part of a faction for build requirements") and return unless faction or self.class.build_requirements.empty?

        self.class.build_requirements.each do |requirement|
          case requirement[:validates]
            when :presence_of then
              begin
                requirement[:class_symbols].each do |asset_symbol|
                  errors.add(:base, "Required #{asset_symbol} does not exist") and return unless required_class_type = Asset::Manager[asset_symbol]
                  errors.add(:base, "Requires #{asset_symbol} to build") if faction.assets.where(:type => required_class_type.name).count.zero?
                end
              end

          end
        end
      end

      if self.building_size # we have a presence on the map. validate it
        # Check if the position matches the grid
        errors.add(:location, "is not on the grid") unless grid_position?(location)
        # check if there is space available
        errors.add(:location, "has no space to build #{self.class.internal_name}") unless building_space_available?(location, building_size)
      end
    end
  end

end
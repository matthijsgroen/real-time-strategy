module Asset::Support::ActiveRecord

  module InstanceMethods

    def on_map?
      !location.nil?
    end

    # Explicit declaration to allow method chaining
    def location
      read_attribute :location
    end

    def release asset
      found_asset          = assets.find_by_id asset.id
      return false unless found_asset
      found_asset.location = self.exit_point
      found_asset.save!
      found_asset
    end

    def place_in asset
      asset.location = nil
      self.assets << asset
    end

    def part_of_with_instance_setting= value
      self.part_of_without_instance_setting = value
      if value
        self.location = nil
        copy_instance_setting_from value
      end
    end

    def bound_to_with_instance_setting= value
      self.bound_to_without_instance_setting = value
      if value
        copy_instance_setting_from value
      end
    end

    private

    def copy_instance_setting_from asset
      self.faction_id       = asset.faction_id || asset.faction.id
      self.faction          = asset.faction
      self.game_instance_id = asset.game_instance_id || asset.game_instance.id
      self.game_instance    = asset.game_instance
    end

    def update_building_size
      l = location_without_movement
      if bs = self.building_size
        write_attribute :ground_space, LineString.from_coordinates([
                [l.x, l.y],
                        [l.x + bs[:width].grid, l.y],
                        [l.x + bs[:width].grid, l.y + bs[:height].grid],
                        [l.x, l.y + bs[:height].grid],
                        [l.x, l.y]
        ])
      end
    end

    def set_asset_info
      self.action_radius = self.sight if self.sight
    end
  end

  module ClassMethods

  end

  def self.included base
    base.extend ClassMethods
    base.class_eval do
      include Asset::Support::ActiveRecord::InstanceMethods

      set_table_name "assets"

      belongs_to :faction, :class_name => "Faction::Base"
      belongs_to :bound_to, :class_name => "Asset::Base"
      alias_method_chain :bound_to=, :instance_setting

      belongs_to :part_of, :class_name => "Asset::Base"
      alias_method_chain :part_of=, :instance_setting

      has_many :assets, :class_name => "Asset::Base", :foreign_key => "part_of_id"

      # validations
      validates_presence_of :game_instance_id
      validates_presence_of :location, :unless => :part_of_id
      validates_presence_of :part_of_id, :unless => :location

      # accessors
      scope :of_type, lambda { |type| where(:type => Asset::Manager[type].name) }
      scope :hostile, lambda { |own_faction| where("faction_id <> ?", own_faction.id) }
      scope :distinct_types, select("DISTINCT ON(assets.type) assets.type, assets.*")
      scope :closest_at, lambda { |location, distance|
        position  = case location
                      when Point then
                        location
                      when Asset::Base then
                        location.location
                    end
        sql_point = "GeomFromText('#{position.text_geometry_type}(#{position.text_representation})',-1)"
        select("assets.*").joins("LEFT JOIN asset_movements ON asset_movements.asset_id = assets.id").
                where("ST_DWithin(assets.location, #{sql_point}, #{distance})" +
                " OR ST_DWithin(asset_movements.path, #{sql_point}, #{distance})")
      }
      has_and_belongs_to_many :scripts,
              :join_table              => "script_assets",
              :class_name              => "Script::Base",
              :foreign_key             => "asset_id",
              :association_foreign_key => "script_id"
      before_create :set_asset_info
      before_save :update_building_size
    end
  end

end
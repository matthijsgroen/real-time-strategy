#
# = Assets
# Every fysical object that appears on the map of a game instance is an asset.
# Assets can be interactive and potentially destructible.
# Things that are assets:
# * a tree, a big rock
# * a building
# * a moveable fighting unit
#
# == Attributes
# An asset has a set of attributes that can be set. They don't need all to have a value.
# eg: For an tree only size matters, but for an combat unit the sight and attack strength matter
# The following attributes are defined:
# for construction:
# - build_time
# - build_costs
# for operation: (not implemented yet)
# - operating_costs
# - operating_requires
# for movement:
# - movement_speed
# for combat:
# - sight
# - hitpoints
# for production:
# - queue_size
# for fysical construction:
# - size -- the size in grid blocks from the top left corner. a grid block is 32 by 32 pixels. The value is an \
# hash with the keys <tt>:width</tt> and <tt>:height</tt> sizes are integer. eg. <tt>size :width => 3, :height => 2</tt>  
# - exit_point -- array containing coordinates originating from the top-left corner (the location) of the asset
#
# The meta-class insertion of these properties is through the info class method. see Asset::Support::Info
#
# == Abilities
# abilities make the asset interactive.
# They are added using "has_ability" see Asset::Support::Abilities for more information.
#
# == Requirements
# special building requirements like prerequisite buildings. see Asset::Support::Requirements
#
# == States
# states this asset can be in. An asset can be in multiple states at a time, like: production, damaged.
# see Asset::Support::States
#
# == Weapons
# An asset can have multiple weapons at it's disposal. see Asset::Support::Combat
#
# == Movement and Proximity detection
# An asset with a sight gets notifications if other assets come into sight or are leaving the sight.
# If an asset is on the move, this module will help with providing the current location.
# see Asset::Support::Movement
#
#
class Asset::Base < ActiveRecord::Base

  set_table_name "assets"

  def self.metaclass;
    class << self;
      self;
    end;
  end

  include Extensions::GameTime
  include Asset::Support::ActiveRecord
  include Asset::Support::Requirements
  include Asset::Support::Info
  include Asset::Support::Abilities
  include Asset::Support::States
  include Asset::Support::Movement
  include Asset::Support::Combat

  after_initialize :variable_setup

  info :build_time, # building info
  :build_costs, # operational info
  :operating_costs, :operating_requires, # movement info
  :movement_speed, # combat
  :sight, # vitals
  :armor, :hitpoints, # production
  :queue_size, # physical construction
  :building_size

  def inspect
    "#{self.class.internal_name}(#{self.health}/#{self.hitpoints})#{" [#{"%.1f" % location.x}, #{"%.1f" % location.y}]" if location}"
  end

  private

  def variable_setup
    (self.class.info || {}).each do |k, v|
      instance_variable_set("@#{k}", v)
    end
    @classifications = self.class.classifications || []
  end

end
#
# This module extends the Asset::Base class with meta information.
# the attributes that will be declared are in Asset::Base
#
module Asset::Support::Info

  def self.included(base)
    base.extend(ClassMethods)
  end

  # returns the classifications of this asset
  attr_reader :classifications

  # Tests if the given classifications matches with the classifications of this asset.
  # If one given classification is true, this method returns true.
  def meets_classifications?(*arr)
    tests = arr.flatten
    tests.each { |classification| return true if classifications.include? classification }
    return false
  end

  #
  # This module extends the Asset::Base class with meta information.
  # the attributes that will be declared are in Asset::Base
  #
  module ClassMethods

    # Adds properties to the asset. Provide a list of names
    # and this method creates properties on class level, wich
    # can be set by all extending classes on class level.
    # All values and properties are also available on instance
    # level and can be overridden there for upgrades for example.
    def info(*arr)
      return @info if arr.empty?
      # 1. Set up accessors for each variable on instance level
      attr_reader *arr
      # 2. Add a new class method to for each trait on class instance level
      arr.each do |a|
        metaclass.instance_eval do
          define_method(a) do |val|
            @info    ||= {}
            @info[a] = val
          end
        end
      end
    end

    # Set a list of classifications for this asset.
    # e.g.:
    # - :ground for ground units
    # - :air for air units
    # - :ground, :building for buildings
    # you can also place the general role of the unit in it
    # so that A.I. construction can use it to identify asset types
    # e.g. :militairy, :worker, :resource
    def classifications(*arr)
      return @classifications if arr.empty?
      @classifications = arr
    end

    # The internal name of the unit. also use as a shorthand.
    # This way a unit name can be generated in debug info instead of using the full class name.
    # Calling this method also registers this asset to Asset::Manager
    def internal_name(name_symbol = nil)
      if name_symbol
        @internal_name = name_symbol
        Asset::Manager.register_type(self, name_symbol)
      end
      @internal_name
    end

#    def properties(*arr)
#      return @properties if arr.empty?
#
#      # 1. Set up accessors for each variable
#      attr_accessor *arr
#    end
  end

end

# Be sure to restart your server when you modify this file.

class Numeric

  def kilo;
    self * 1000.0;
  end

  def meter;
    self * 1.0;
  end

  alias :meters :meter

  def mile;
    self * 1609.344;
  end

  alias :miles :mile

  def feet;
    self * 3.2808399;
  end

  def kmph;
    self.kilo.meter / 1.hour;
  end

  def mph;
    self.mile / 1.hour;
  end

  def oil;
    {:oil => self};
  end

  def metal;
    {:metal => self};
  end

  def energy;
    {:energy => self};
  end

  def supply;
    {:supply => self};
  end

  def grid;
    self * 32;
  end

  def to_speed
    Math.log(self) * 80.0
  end

  def to_distance
    self * 60.0
  end

end

class Hash

  def +(other_hash)
    self.merge(other_hash) { |key, oldval, newval| oldval + newval }
  end

end

class Symbol
  def to_id
    "#{self}_id".to_sym
  end
end

#GeoRuby::SimpleFeatures.default_srid = -1

#module GeoRuby::SimpleFeatures
#  #TODO: Remove this when geo_ruby is properly updated
#  DEFAULT_SRID = -1
#end
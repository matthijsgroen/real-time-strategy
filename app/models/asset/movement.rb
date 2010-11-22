class Asset::Movement < ActiveRecord::Base
  set_table_name "asset_movements"
  belongs_to :asset, :class_name => "Asset::Base"
  belongs_to :proximity_trigger, :class_name => "Asset::ProximityTrigger", :dependent => :destroy
  belongs_to :game_instance

  after_create :notify_assets_in_proximity

  def location(time = Time.now)
    progress = (time - departure_at).to_f / (arrival_at - departure_at).to_f
    x        = origin.x + ((origin.x - destination.x) * progress)
    y        = origin.y + ((origin.y - destination.y) * progress)
    Point.from_x_y x, y
  end

  def origin
    path.points.first
  end

  def destination
    path.points.last
  end

  private

  def notify_assets_in_proximity
    #puts "checking other items for proximity. #{I18n.l departure_at, :format => "%H:%M:%S"}"
    first_part      = LineString.from_points [path.points.first, path.points.second]
    path            = "ST_GeomFromText('#{first_part.text_geometry_type}(#{first_part.text_representation})')"

    assets_in_range = asset.game_instance.assets.find :all,
            :select     => "assets.*, asText(ST_Intersection(#{path}, ST_Buffer(assets.location, assets.action_radius))) AS intersection",
            :conditions => "ST_DWithin(assets.location, #{path}, assets.action_radius) AND id <> #{asset.id}"
    assets_in_range.each do |asset_in_proximity|
      intersecting_line = GeoRuby::SimpleFeatures::Geometry.from_ewkt(asset_in_proximity.intersection)
      in_range = time_on_point intersecting_line.points.first if intersecting_line.points.first != destination
      out_of_range = time_on_point intersecting_line.points.last if intersecting_line.points.last != destination
      in_out_range      = [in_range, out_of_range].compact.sort
      in_range, out_of_range = in_out_range[0], in_out_range[1]

      puts "#{self.asset.inspect} in range of #{asset_in_proximity.inspect}: " +
              "#{I18n.l in_range, :format => "%H:%M:%S"} - #{out_of_range ? I18n.l(out_of_range, :format => "%H:%M:%S") : "n/a"} arrival: #{I18n.l arrival_at, :format => "%H:%M:%S"}"
      build_proximity_trigger.tap do |t|
        t.alerted_asset_id      = asset_in_proximity.id
        t.asset_in_proximity_id = self.asset_id
        t.in_range_at           = in_range
        t.out_of_range_at       = out_of_range ? out_of_range + 1 : nil
        t.game_instance_id      = self.asset.game_instance_id
        t.save
      end
    end
  end

  def time_on_point point
    # A               c      B
    # *---------------.------*
    # 100             30     10
    # 10              80     110
    if origin.x != destination.x
      progress = (point.x.to_f - origin.x) / (destination.x.to_f - origin.x)
    else
      progress = (point.y.to_f - origin.y) / (destination.y.to_f - origin.y)
    end
    #puts "progress: #{progress}"
    departure_at + ((departure_at - arrival_at) * progress)
  end

end

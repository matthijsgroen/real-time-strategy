# = Factions
# A faction is a player in an instanced environment. A faction can be either a human or a computer player.
# == Resources
# A faction has the following resources declared: see Extensions::Resources::ClassMethods
# - Oil -- resource compound needed for construction and research
# - Metal -- resources compound needed for construction and research
# - Energy -- needed to power buildings
# - Supply -- needed to feed troops
#
class Faction::Base < ActiveRecord::Base
  set_table_name "factions"
  belongs_to :game_instance

  validates_presence_of :game_instance_id, :name, :description
  validates_uniqueness_of :name, :scope => :game_instance_id
  has_many :assets, :class_name => "Asset::Base",
          :before_add => :set_game_instance, :foreign_key => "faction_id", :dependent => :destroy
  has_many :catalogs, :class_name => "Faction::Catalog", :foreign_key => "faction_id", :dependent => :destroy do

    def add_full_catalogs_of(asset_type)
      asset_class = Asset::Manager[asset_type]
      asset_class.catalog_abilities.collect do |ability|
        catalog_items = asset_class.ability_catalogs[ability]
        catalog = proxy_owner.catalogs.find_or_create_by_asset_type_and_ability(asset_type.to_s, ability.to_s)
        catalog.items.delete_all
        catalog_items.each do |item|
          catalog.items << Faction::CatalogItem.create(:item_type => item.to_s)
        end
        catalog.items
      end
    end

  end
  has_many :messages, :class_name => "Faction::Message", :foreign_key => "faction_id", :dependent => :destroy

  include SelectionSupport

  has_resource :oil, :amount => 0, :limit => 1000 #, :income => 1.0 / 5.seconds
  has_resource :metal, :amount => 0
  has_resource :energy, :amount => 0
  has_resource :supply, :amount => 0

  private

  def set_game_instance(asset)
    asset.game_instance_id = self.game_instance_id
  end

end

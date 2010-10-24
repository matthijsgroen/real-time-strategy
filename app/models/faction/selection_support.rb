module Faction::SelectionSupport

  module InstanceMethods

    def active_selection
      @active_selection ||= selections.find_or_create_by_hotkey nil
    end

    def assign_selection_to(hotkey)
      hotkey_selection = Faction::Selection.find_or_create_by_hotkey hotkey
      hotkey_selection.assets.clear
      hotkey_selection.assets << active_selection.assets
    end

    def load_selection(hotkey)
      hotkey_selection = Faction::Selection.find_or_create_by_hotkey hotkey
      active_selection.assets.clear
      active_selection.assets << hotkey_selection.assets
    end

  end

  module ClassMethods

  end

  def self.included(base)
    #base.extend(ClassMethods)
    base.class_eval do
      include Faction::SelectionSupport::InstanceMethods
      has_many :selections, :class_name => "Faction::Selection", :foreign_key => "faction_id", :dependent => :destroy
    end
  end

end
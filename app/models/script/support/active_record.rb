module Script::Support::ActiveRecord

  def self.included(base)
    base.extend(ClassMethods)
    base.class_eval do
      include Script::Support::ActiveRecord::InstanceMethods

      # relations
      belongs_to :game_instance
      belongs_to :faction, :class_name => "Faction::Base"
      belongs_to :initiated_by, :polymorphic => true

      # validations
      validates_presence_of :game_instance_id
      serialize :parameters, Hash
      belongs_to :parent, :class_name => "Script::Base"
      has_and_belongs_to_many :assets,
              :join_table              => "script_assets",
              :class_name              => "Asset::Base",
              :foreign_key             => "script_id",
              :association_foreign_key => "asset_id"
    end
  end

  module InstanceMethods

  end

  module ClassMethods

  end

end
module Asset::Support::States

  def self.included(base) # :nodoc:
    base.class_eval do
      include Asset::Support::States::InstanceMethods
      has_many :states, :class_name => "Asset::State", :foreign_key => "asset_id", :dependent => :destroy
    end
  end

  module InstanceMethods

    def is_in_state?(state)
      states.find_by_state state.to_s
    end

    def put_in_state(state)
      return if is_in_state? state
      states << Asset::State.create(:state => state.to_s)
    end

    def remove_state(state)
      return unless existing = is_in_state?(state)
      existing.destroy
    end

  end

end
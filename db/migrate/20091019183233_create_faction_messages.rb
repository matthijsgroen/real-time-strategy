class CreateFactionMessages < ActiveRecord::Migration
  def self.up
    create_table :faction_messages do |t|
      t.references :faction
      t.string :sender
      t.string :message
      t.string :type

      t.timestamps
    end
  end

  def self.down
    drop_table :faction_messages
  end
end

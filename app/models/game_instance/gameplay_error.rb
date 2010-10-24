class GameInstance::GameplayError < StandardError

	def initialize(game_object, message, key)
		super(message)
		@game_object = game_object
		@const_key = key
	end

	attr_reader :game_object, :const_key

end
extends Control

@export var loggerPrefix = "Game"

@export var gold := 100
@export var greed := 0
@export var popularity := 50

@export var flags: Array = []

@export var current_card: Dictionary = {}


func _ready():
	randomize()

	CardLoader.load_cards()

	next_card()


func next_card():

	current_card = CardLoader.get_random_card(self)

	if current_card.is_empty():
		Log.Warn("No available cards.", loggerPrefix)
		return

	Log.Info("", loggerPrefix)
	Log.Info("===== NEW CARD =====", loggerPrefix)
	Log.Info(current_card.title, loggerPrefix)
	Log.Info(current_card.description, loggerPrefix)

	for option in current_card.options:
		Log.Info(option.id + " -> " + option.title, loggerPrefix)


func choose(option_id: String):

	for option in current_card.options:

		if option.id != option_id:
			continue

		CardLoader.apply_effects(self, option.effects)

		Log.Info("", loggerPrefix)
		Log.Info("Gold:" + str(gold), loggerPrefix)
		Log.Info("Greed:" + str(greed), loggerPrefix)
		Log.Info("Popularity:" + str(popularity), loggerPrefix)
		Log.Info("Flags:" + str(flags), loggerPrefix)

		next_card()
		return

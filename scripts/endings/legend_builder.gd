class_name LegendBuilder
extends RefCounted

const LEGEND_TRAIT_CATALOG := preload("res://scripts/traits/legend_trait_catalog.gd")
const ENDINGS := {
	"dragon_defender": {
		"title": "Guardian of the Dragon",
		"epilogue": "You stood between the colossal dragon and the valley. In time, even those who once feared the creature spoke of the hero who taught power to show mercy."
	},
	"dragon_master": {
		"title": "Master of Dragons",
		"epilogue": "The dragon bowed, and the realm learned to fear the authority in your voice. Whether your command brought safety or merely a different danger became a question for future legends."
	},
	"dragon_thief": {
		"title": "Thief of the Dragon's Hoard",
		"epilogue": "You escaped beneath the dragon's fury carrying a fortune. The valley survived without your aid, and every glittering coin carried the memory of what you chose to leave behind."
	},
	"kingdom_savior": {
		"title": "Savior of the Kingdom",
		"epilogue": "When the fortress darkened the sky, you rallied a frightened kingdom. The people remembered that courage did not require a crown—only someone willing to stand first."
	},
	"fortress_conqueror": {
		"title": "Conqueror of the Skies",
		"epilogue": "You claimed the floating fortress and the power within it. From that day forward, every ruler watched the clouds and wondered whether you would arrive as protector or sovereign."
	},
	"kingdom_opportunist": {
		"title": "The Gilded Opportunist",
		"epilogue": "While the kingdom fought for survival, you built a fortune from its abandoned treasures. You became wealthy beyond measure, though some doors closed whenever your name was spoken."
	},
	"world_tree_chosen": {
		"title": "Chosen of the World Tree",
		"epilogue": "You accepted the ancient gift and became something greater—and stranger—than the person who began this journey. The roots still whisper your name beneath the earth."
	},
	"world_tree_guardian": {
		"title": "Guardian of the World Tree",
		"epilogue": "You sealed away a power no mortal was meant to wield. Few understood what you sacrificed, but generations lived safely beneath branches that never again stirred."
	},
	"world_tree_wanderer": {
		"title": "The One Who Walked Away",
		"epilogue": "You refused the promise of unimaginable power. Some called the choice wisdom and others called it fear, but the road remained yours—and you continued down it freely."
	}
}


func build_summary(
	hero: Dictionary,
	gold: int,
	greed: int,
	popularity: int,
	flags: Array,
	journey: Array[Dictionary]
) -> Dictionary:
	var ending: Dictionary = _find_ending(flags)
	var trait_catalog = LEGEND_TRAIT_CATALOG.new()
	return {
		"ending_id": str(ending.id),
		"title": ending.title,
		"hero_title": str(hero.get("title", "Unknown Hero")),
		"epilogue": str(ending.epilogue) + "\n\n" + _build_legacy_text(gold, greed, popularity),
		"gold": gold,
		"greed": greed,
		"popularity": popularity,
		"traits": trait_catalog.format_traits(flags),
		"journey": _build_journey_text(journey)
	}


func _find_ending(flags: Array) -> Dictionary:
	for ending_flag in ENDINGS:
		if flags.has(ending_flag):
			var ending: Dictionary = ENDINGS[ending_flag].duplicate(true)
			ending["id"] = ending_flag
			return ending
	return {
		"id": "unwritten_legend",
		"title": "An Unwritten Legend",
		"epilogue": "Your journey ended in a way no chronicler expected."
	}


func get_ending_definitions() -> Array[Dictionary]:
	var definitions: Array[Dictionary] = []
	for ending_id in ENDINGS:
		definitions.append({
			"id": str(ending_id),
			"title": str(ENDINGS[ending_id].title)
		})
	return definitions


func _build_legacy_text(gold: int, greed: int, popularity: int) -> String:
	var reputation_text: String
	if popularity >= 50:
		reputation_text = "Songs of your deeds traveled farther than you ever did."
	elif popularity >= 15:
		reputation_text = "Most people remembered your name with admiration."
	elif popularity >= 0:
		reputation_text = "Your reputation remained uncertain, shaped by equal parts praise and rumor."
	else:
		reputation_text = "Your name was spoken carefully, and seldom with affection."

	var character_text: String
	if greed >= 35:
		character_text = "Opportunity had become your compass, whatever the cost."
	elif greed >= 10:
		character_text = "You rarely ignored an opportunity to improve your own fortune."
	elif greed > -10:
		character_text = "Ambition and conscience remained in uneasy balance."
	else:
		character_text = "You repeatedly placed others before yourself."

	var fortune_text: String
	if gold >= 100:
		fortune_text = "You ended your travels with a remarkable fortune."
	elif gold >= 30:
		fortune_text = "You ended your travels with enough gold for whatever road came next."
	else:
		fortune_text = "You ended your travels with little gold, but wealth was only one measure of a life."
	return reputation_text + " " + character_text + " " + fortune_text


func _build_journey_text(journey: Array[Dictionary]) -> String:
	var lines: Array[String] = []
	for entry in journey:
		lines.append(
			"• " + str(entry.get("card_title", "Unknown Event"))
			+ ": " + str(entry.get("option_title", "Unknown Choice"))
		)
	if lines.is_empty():
		return "No deeds were recorded."
	return "\n".join(lines)

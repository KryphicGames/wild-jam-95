class_name LegendTraitCatalog
extends RefCounted

const TRAITS: Dictionary = {
	"helped_orphan": {"name": "Sheltering Hand", "description": "You stayed when a child needed someone."},
	"ignored_orphan": {"name": "Averted Eyes", "description": "You left a helpless child beside the road."},
	"saved_wolf": {"name": "Wolf's Trust", "description": "A wild creature remembers your mercy."},
	"killed_wolf": {"name": "Pack's Ire", "description": "The wilderness remembers the blood you spilled."},
	"honored_shrine": {"name": "Shrine's Blessing", "description": "An ancient presence accepted your respect."},
	"desecrated_shrine": {"name": "Shrine's Curse", "description": "Something sacred follows your footsteps."},
	"opened_mysterious_box": {"name": "Shadow-Touched", "description": "The box opened something within your shadow."},
	"returned_mysterious_box": {"name": "A Favor Owed", "description": "A hooded stranger remembers your restraint."},
	"returned_ring": {"name": "Honest Finder", "description": "You returned something precious to its owner."},
	"kept_ring": {"name": "Keeper of the Ring", "description": "A lost heirloom remained in your possession."},
	"traded_fairly": {"name": "Fair Dealer", "description": "Merchants remember that your word has value."},
	"robbed_merchant": {"name": "Marked by Merchants", "description": "Traders warn one another when you approach."},
	"orphan_bond": {"name": "Found Family", "description": "The child you helped became part of your legend."},
	"orphan_informant": {"name": "Eyes on the Road", "description": "A young ally listens for dangers ahead."},
	"orphan_rejected": {"name": "Twice Abandoned", "description": "You turned away the same child a second time."},
	"wolf_pack_allies": {"name": "Friend of the Pack", "description": "The wolf pack now answers your call."},
	"outwitted_pack": {"name": "Pack-Clever", "description": "You escaped the wolves through cunning."},
	"avoided_wolf_pack": {"name": "Wary Traveler", "description": "You learned when survival meant choosing another road."},
	"shrine_reconciled": {"name": "Shrine-Keeper", "description": "Your bond with the ancient shrine was renewed."},
	"shrine_relic_claimed": {"name": "Relic Bearer", "description": "You carry a relic claimed from sacred ground."},
	"shrine_connection_broken": {"name": "Forsaken by the Shrine", "description": "The ancient presence has withdrawn its favor."},
	"box_mystery_faced": {"name": "Shadow-Faced", "description": "You confronted the mystery that once escaped its box."},
	"shadow_contract_expanded": {"name": "Deeply Shadow-Bound", "description": "Your agreement with the shadow grew stronger."},
	"box_secret_sold": {"name": "Seller of Secrets", "description": "You found a buyer for knowledge best left hidden."},
	"ring_truth_told": {"name": "Bearer of Truth", "description": "You revealed the ring's history when it mattered."},
	"ring_bargain_struck": {"name": "Heirloom Broker", "description": "You turned a disputed inheritance into a bargain."},
	"ring_claim_denied": {"name": "Unyielding Keeper", "description": "You refused to surrender the ring when challenged."},
	"merchant_trust_earned": {"name": "Trusted Trader", "description": "A merchant placed their confidence in your judgment."},
	"merchant_favor_claimed": {"name": "Favor Collected", "description": "You knew exactly when to call in an old debt."},
	"merchant_avoided": {"name": "Trade-Wary", "description": "Experience taught you to walk past a tempting offer."},
	"kept_dragon_egg": {"name": "Bearer of the Egg", "description": "A dragon's future travels in your care."},
	"sold_dragon_egg": {"name": "Seller of the Egg", "description": "You placed a price on a dragon's future."},
	"destroyed_dragon_egg": {"name": "Dragon's Bane", "description": "Your hand ended one dragon and awakened another."},
	"dragon_protected": {"name": "Dragon's Guardian", "description": "You raised a feared creature with protection."},
	"dragon_trained": {"name": "Dragon Trainer", "description": "The dragon learned to recognize your command."},
	"accepted_bargain": {"name": "Witch-Bound", "description": "A bargain ties your fate to forbidden knowledge."},
	"stole_spellbook": {"name": "Spellbook Thief", "description": "Stolen magic whispers from your belongings."},
	"refused_witch": {"name": "Unbent", "description": "You refused power when it was freely offered."},
	"accepted_summons": {"name": "Called by the Crown", "description": "The kingdom placed its crisis before you."},
	"refused_summons": {"name": "Crown-Defier", "description": "You refused the command of a desperate kingdom."},
	"challenger_mentored": {"name": "Honorable Mentor", "description": "You taught strength without humiliation."},
	"stars_understood": {"name": "Reader of Stars", "description": "You completed knowledge lost to generations."},
	"auction_exposed": {"name": "Honest Broker", "description": "You used a merchant's eye to expose corruption."},
	"auction_manipulated": {"name": "Market Maker", "description": "You bent an auction to serve your own fortune."},
	"challenger_defeated": {"name": "Proven Champion", "description": "You answered a challenge with undeniable strength."},
	"challenge_refused": {"name": "Above the Challenge", "description": "You refused to let pride choose your battle."},
	"observatory_preserved": {"name": "Keeper of Knowledge", "description": "You protected an observatory for future scholars."},
	"star_charts_sold": {"name": "Dealer in Discovery", "description": "You put a price on the secrets of the stars."},
	"petitioners_advised": {"name": "Counselor to the People", "description": "Ordinary people trusted your learned judgment."},
	"magistrate_endorsed": {"name": "Voice of Authority", "description": "Your counsel strengthened the local magistrate."},
	"magistrate_opposed": {"name": "People's Advocate", "description": "You challenged authority on behalf of petitioners."},
	"gilded_bargain": {"name": "Gilded Pact", "description": "You accepted wealth with an uncertain price."},
	"gilded_door_looted": {"name": "Fortune-Taker", "description": "You seized the riches beyond the gilded door."},
	"gilded_door_refused": {"name": "Untempted", "description": "You left extraordinary wealth untouched."},
	"dragon_defender": {"name": "Legendary Guardian", "description": "You stood between a dragon and the realm."},
	"dragon_master": {"name": "Dragon Master", "description": "A colossal dragon answered your command."},
	"dragon_thief": {"name": "Hoard-Thief", "description": "You escaped with a dragon's fortune."},
	"kingdom_savior": {"name": "Kingdom's Shield", "description": "You rallied a realm beneath a darkened sky."},
	"fortress_conqueror": {"name": "Sky Sovereign", "description": "You claimed a fortress from the clouds."},
	"kingdom_opportunist": {"name": "Gilded Opportunist", "description": "You found fortune while a kingdom burned."},
	"world_tree_chosen": {"name": "World Tree's Chosen", "description": "Ancient power transformed your legend."},
	"world_tree_guardian": {"name": "Keeper of the Seal", "description": "You bound a power no mortal should wield."},
	"world_tree_wanderer": {"name": "The One Who Left", "description": "You walked away from unimaginable power."}
}


func get_visible_traits(flags: Array, maximum_count: int = 4) -> Array:
	var visible_traits: Array = []
	for flag_index in range(flags.size() - 1, -1, -1):
		var flag_name: String = str(flags[flag_index])
		if !TRAITS.has(flag_name):
			continue
		var trait_data: Dictionary = TRAITS[flag_name].duplicate(true)
		trait_data["flag"] = flag_name
		visible_traits.append(trait_data)
		if visible_traits.size() >= maximum_count:
			break
	return visible_traits


func format_traits(flags: Array, maximum_count: int = 4) -> String:
	var lines: Array[String] = []
	for trait_data in get_visible_traits(flags, maximum_count):
		lines.append(
			"[b]" + str(trait_data.get("name", "Unknown Trait")) + "[/b]\n"
			+ str(trait_data.get("description", ""))
		)
	return "\n\n".join(lines)

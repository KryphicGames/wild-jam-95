# Event Card Classification

Every event card in `res://cards/` defines a `card_type`. The card loader uses
this field to decide how a card participates in quest pacing.

## Supported Types

- `standalone`: An independent event. It can be drawn whether or not a quest is
  active, provided its normal trigger requirements pass.
- `quest_start`: The first card in a quest. It cannot be drawn while another
  quest is active.
- `quest_step`: A middle card in an active quest. Its trigger flags identify the
  required story branch.
- `quest_end`: A quest finale. Its trigger flags identify when the finale is
  ready, and its choice effects must remove `active_quest`.

## Draw Behavior

The loader first removes used, non-repeatable cards and cards whose type or
triggers make them ineligible. It then chooses uniformly from the remaining
cards. As a result, an eligible quest continuation has the same chance as each
eligible standalone event, allowing unrelated encounters between quest stages.

Quest progression remains flag-driven. A quest-start choice adds
`active_quest` and its branch flag. Quest steps replace branch flags as the
story advances. Every quest-ending choice removes `active_quest` and the
quest's temporary progression flags.

## Choice Requirements

An option may define requirements that are checked in addition to whether the
player can afford its Gold cost. Unavailable choices remain visible but cannot
be selected, allowing the finale to show how earlier quest decisions opened or
closed different paths.

```json
{
  "requirements": {
    "any_flags": ["dragon_protected", "dragon_pursued"],
    "not_flags": ["dragon_abandoned"],
    "stats": {
      "popularity": {"min": 10}
    }
  },
  "locked_reason": "Your history with the dragon does not support this path."
}
```

- `flags`: every listed flag must be present.
- `any_flags`: at least one listed flag must be present.
- `not_flags`: none of the listed flags may be present.
- `stats`: each named stat may specify a `min`, a `max`, or both.
- `locked_reason`: optional player-facing text explaining why the choice is
  unavailable.

An option may also define `result`. This is the short narrative shown during
the resolution beat after the player makes that choice. If omitted, the option
description is used instead.

## Callback Variants

A callback card can use `trigger.any_flags` when any one of several earlier
decisions should make it eligible. Unlike `trigger.flags`, which requires every
listed flag, `any_flags` requires at least one match.

The optional `variants` object maps an earlier flag to replacement presentation
fields. When the card is drawn, the loader copies fields such as `title` and
`description` from the first matching variant. Options shared by every version
remain on the main card definition.

```json
{
  "trigger": {
    "flags": [],
    "any_flags": ["helped_orphan", "ignored_orphan"],
    "not_flags": []
  },
  "variants": {
    "helped_orphan": {
      "title": "A Promise Remembered",
      "description": "The child returns to thank you."
    },
    "ignored_orphan": {
      "title": "The Child You Left Behind",
      "description": "The child remembers being abandoned."
    }
  }
}
```

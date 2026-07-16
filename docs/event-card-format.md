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

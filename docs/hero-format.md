# Hero JSON Format

Hero definitions are stored as individual `.json` files in `res://heroes/`.
Each file describes one selectable hero and their starting state. Runtime event
choices do not modify these files.

## Example

```json
{
  "id": "scholar",
  "title": "The Scholar",
  "description": "A short description shown during hero selection.",
  "image": "res://assets/textures/ScholarIdleAnim.png",
  "image_region": {
    "x": 0,
    "y": 0,
    "width": 16,
    "height": 16
  },
  "starting_stats": {
    "gold": 15,
    "greed": 0,
    "popularity": 10
  },
  "starting_flags": [
    "hero_scholar"
  ]
}
```

## Fields

- `id`: Unique, stable identifier. Use lowercase letters, numbers, and underscores.
- `title`: Name displayed to the player.
- `description`: Selection-screen description of the hero.
- `image`: Godot resource path for a portrait. Use an empty string when unavailable.
- `image_region`: Optional rectangular crop when `image` is a sprite sheet. Its
  `x`, `y`, `width`, and `height` values are measured in source-image pixels.
- `starting_stats`: Numeric starting values for `gold`, `greed`, and `popularity`.
- `starting_flags`: Story flags copied into the new run. A `hero_<id>` flag lets
  event cards target a particular hero.

## Requirements

- At least three valid hero files are needed to begin a run.
- Hero IDs must be unique across all files.
- Every required field and starting stat must be present.
- Starting flags must be non-empty strings.
- A non-empty image path must refer to an existing Godot resource.

Invalid definitions are logged and excluded from the selection draw.

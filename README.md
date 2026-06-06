# LockpickTooltip
### World of Warcraft 1.12.1 (Vanilla) Addon — v1.2.0 Stable

Adds a line to item and world-object tooltips showing the required Lockpicking skill, colour-coded green if you can pick it or red if your skill is too low.

---

## Features

- Works on **bag items** (lockboxes, junkboxes)
- Works on **world objects** (chests, doors, footlockers)
- Works in **loot windows**, **merchant windows**, **chat item links**, and **quest windows**
- Colour-coded tooltip line:
  - Green **Pickable (175)** — your skill meets the requirement
  - Red **Skill Level Too Low (225)** — your skill is too low
- Slash command `/lpt` or `/lockpick` for help and item lists

---

## Installation

1. Copy the `LockpickTooltip` folder into:
   ```
   World of Warcraft/Interface/AddOns/
   ```
2. Launch WoW and make sure **LockpickTooltip** is enabled in the AddOns list at the character select screen.

---

## Slash Commands

| Command | Description |
|---|---|
| `/lpt` | Show help |
| `/lpt items` | List all known lockbox items and their requirements |
| `/lpt objects` | List all known lockable world objects and their requirements |

---

## Covered Content

**Lockbox Items**
- All junkboxes: Battered, Worn, Sturdy, Heavy
- Crafted lockboxes: Ornate Bronze, Heavy Bronze, Iron, Strong Iron, Steel, Reinforced Steel, Mithril, Thorium, Eternium
- Gnomish Lock Box

**World Objects**
- Rogue training boxes: Buccaneer's Strongbox, Practice Lockbox
- Outdoor chests across all Classic zones
- Dungeon chests: Shadowfang Keep, Gnomeregan, Scarlet Monastery, Uldaman, Zul'Farrak, Maraudon, Sunken Temple, Blackrock Depths, Blackrock Spire, Dire Maul, Scholomance, Stratholme
- Lockable doors: SM Cathedral, Gnomeregan, Scholomance, Stratholme Service Entrance

---

## Version History

**1.2.0** — Stable. Full zone-aware footlocker coverage from spreadsheet data (Battered, Waterlogged, Mossy, Dented). Multi-variant footlockers now use the game's own "Locked" text colour to determine which variant is present, showing a single accurate line instead of multiple. Added Scarlet Footlocker (Eastern Plaguelands, 250). All dungeon door skill requirements corrected. Added Deadmines and Dire Maul doors.

**1.1.0** — Zone-aware skill requirements for Battered Footlocker. Corrected all item IDs against wowhead.com/classic. Tooltip now shows Pickable/Skill Level Too Low in green/red.

**1.0.0** — Initial stable release. Full coverage of vanilla lockboxes, junkboxes, and dungeon/outdoor chests.

---

## Known Limitations

- Item and world object coverage is still being tested — some entries may have incorrect skill requirements or missing entries.
- OctoWoW-specific lockable items and objects have not yet been added and will be included in a future update.

# MerfinPlus TBC Raid Cooldowns – renderer-only WeakAura contract

MerfinPlus is the complete backend for the TBC Raid Cooldowns frontend. It owns:

- group roster and connection/death/subgroup state;
- event-driven inspect/talent eligibility;
- combat-log and unit-spell cooldown tracking;
- encounter resets and buff-duration tracking;
- configuration, spell catalog, persistence and rendered state snapshots.

The WeakAura `[Merfin] RCD [Bars] ` is only a renderer. It must not register
combat-log, roster, inspect or cooldown-tracking events.

## Public API

```lua
local api = MerfinPlus and MerfinPlus.RaidCooldowns
  or Merfin and Merfin.RaidCooldowns

local snapshot = api and api.GetSnapshot("[Merfin] RCD [Bars] ")
```

The snapshot contains:

- `schemaVersion`
- `expansion` / `expansionName`
- `frontendSupported`
- `config`
- `catalog`
- `states`
- `revision`
- `updateEvent`

`states` is keyed by the WeakAuras clone key and contains complete timed-state
tables for the existing display, conditions, sorting and click actions.

## Single frontend update event

MerfinPlus fires:

```text
MERFINPLUS_RAID_COOLDOWNS_UPDATED
```

The first event argument is the current complete snapshot. Configuration changes
also rebuild the tracked renderer states and use this same event. The frontend
does not need the separate configuration event.

Use this exact WeakAuras Trigger 1 event line:

```text
MERFINPLUS_RAID_COOLDOWNS_UPDATED, WA_INIT
```

Trigger 1 remains `Custom` / `State Update`. On `WA_INIT`, `STATUS` or `OPTIONS`
it calls `api.GetSnapshot(aura_env.id)`; on the custom update event it consumes
the supplied snapshot and replaces its `allstates` entries.

## Backend retirement

After the renderer-only On Init and Trigger 1 replacements are pasted:

1. disable the old `[Merfin] RCD [Backend]` WeakAura;
2. `/reload`;
3. verify roster bars, a real cooldown cast, a reset/buff case and click actions;
4. only then delete the disabled backend aura.

Triggers used only by the old backend runtime (inspect ticker and inspect/talent
events) must be removed from the frontend. MerfinPlus performs those jobs.

No live WeakAura is changed by the addon installation itself.

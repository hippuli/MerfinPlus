# MFPRA1 Raid Assignments contract

`MFPRA1` is a deliberate breaking replacement for every MGMRA clipboard and
addon-message format. MerfinPlus accepts only this contract at those boundaries.
Older SavedVariables remain private local data and are not renamed or migrated.

## Clipboard envelope

`MFPRA1:` + RFC 4648 padded Base64 of zlib-compressed canonical JSON.

Canonical JSON sorts object keys lexicographically, preserves array order, and
uses the shortest finite JSON decimal representation accepted by both runtimes.
All coordinates and Boss Plan element fields retain the MGMRA4 v4/catalog v1
semantics. The root `h` is lowercase eight-digit Adler-32 of the canonical JSON
with `h` omitted. It is an integrity checksum, not a security signature.

Common root fields:

| Key | Meaning |
| --- | --- |
| `s` | Literal `MFPRA` |
| `v` | Integer `1` |
| `k` | `F` full, `D` boss assignment delta, or `P` one Boss Plan delta |
| `r` | Positive integer revision |
| `h` | Semantic Adler-32 checksum |
| `x` | Literal `tbc` |
| `g` | Canonical raid-group id |

### Full snapshot (`k=F`)

`a` is the complete assignment UI snapshot and `p={c:1,l:[...]}` contains all
enabled Boss Plans as geometry and stable asset IDs only. No texture, icon, or
other binary asset bytes are transported.

### Boss/widget delta (`k=D`)

`b` is the selected boss id. `a.bs` contains exactly that boss and `a.rs` its
raid identity. `p`, Boss Plan geometry, other bosses, and unrelated UI state are
forbidden.

### Boss Plan delta (`k=P`)

`b`, `i`, and `r` identify exactly one boss, plan instance, and saved revision.
`c=1`; `p` is exactly one catalog-v1 plan. A receiver replaces only the matching
plan index in an existing full MFPRA1 snapshot.

## Compact assignment model

- `a={c,rs,bs}`: comp name, raids, bosses.
- Raid: `{i,n,c}`: id, name, comp.
- Boss: `{i,n,q,t,s,tg?,ta?,tm?}`: id, name, raid id, trash flag,
  sections, and optional explicit shared-Trash group, anchor, and ordered raid
  members. `tk_ssc` has one `tk_ssc:trash` record anchored to `tempest_keep`
  with members `[tempest_keep,serpentshrine_cavern]`; `bt_mh` has one
  `bt_mh:trash` record anchored to `black_temple` with members
  `[black_temple,mount_hyjal]`. Shared Trash is rendered before the first raid
  heading and is never duplicated per member raid.
- Section: `{n,o,k,c,w}`: display name, source name, optional semantic category,
  context, rows. `k` is one of `trash-role`, `role`, `position`, `class`,
  `buff`, `additional`, or `utility`.
- Context: `{t,r,b,p}`: type, raid name, boss name, phase.
- Row: `{a,d,n,c,s,k,r,m,tc,ts,l,p,tk,t,g,u,...}`: assignment, display label,
  player, class, spec, semantic row kind, role, marker, target class/spec,
  slot, position, target kind/value, group set, and note/context.
- Row `k` is one of `role`, `position`, `class`, `buff`, `additional`, or
  `utility`; `r` is `tank`, `heal`, `melee`, `ranged`, or `raid`.
- `tk` is `player`, `groups`, `worldmarker`, `role`, `position`, `state`,
  `text`, or `none`. A `groups` target requires `g`, a unique ascending dense
  array of group numbers `1..8`. A `worldmarker` target requires canonical `m`.
  A `player` target requires exact `t`; `tc`/`ts` retain its class/spec when
  known.

Additional rows (`k=additional`) also carry:

- `i`: stable Additional Assignment id; `l` remains its one-based display
  order and the row array remains authoritative.
- `bn`/`bi`: boss-spell name and canonical icon token.
- `wn`/`wi`: custom What text and canonical icon token.
- `an`/`ai`/`ae`: ability name, icon token, and optional Symbiosis flag.
- `cn`/`ci`/`ce`: cooldown name, icon token, and optional Symbiosis flag.
- `x`: custom ability/cooldown text; `v=assignee`: personal/widget visibility.
- Icon tokens are only `spell:<positive integer>` or
  `icon:<lowercase_wow_icon_token>`; URLs and binary assets are forbidden.

Full snapshots show every Additional row in the dedicated Additional
Assignments card. Personal/widget projection shows an Additional row only to
its `n` assignee. `m` renders as a marker icon, `t/tc/ts` remains an optional
recipient, and `u` is the note; absent values produce no placeholders.

Pure position rows use `k=position`, role `r`, slot `l`, full label `p`/`d`,
and `tk=position` with `t` omitted. The UI renders the full label once on the
left and the concise `T/H/M/R + slot` code on the right.

Boss, section, and row arrays are authoritative display order. Full snapshots
retain every Trash and boss block. A received boss delta replaces only the
current boss in the personal widget. Shared `tg` Trash stays pinned across all
ordered `tm` member raids; a member-raid boss delta cannot remove it. A newer
shared Trash delta replaces only that shared scope and preserves the current
boss. Non-shared Trash remains scoped to its `q` raid.

Unknown keys, invalid types, sparse arrays, non-finite/invalid Boss Plan values,
unsupported assets, and limit violations are rejected before state mutation.

## Addon transport

Addon prefix: `MFPRA1` (six bytes; the WoW limit is 16).

- `S|transferId|kind|revision|chunks|bytes|wireHash`
- `D|transferId|index|base64Slice`
- `E|transferId|wireHash`
- `A|transferId|kind|revision|wireHash|applied-or-stale|addonVersion`
- `N|transferId|kind|revision|wireHash|reasonCode`

Data slices are 180 bytes, comfortably below the 255-byte addon-message limit
after framing. `wireHash` is Adler-32 of the exact `MFPRA1:` envelope.

Only explicit Import, Full Sync, boss/widget Send, and saved Boss Plan Send UI
actions may initiate work. Import itself sends nothing. MerfinPlus creates no
recurring transport timer, retry, resend, polling loop, or automatic sync.
ChatThrottleLib may pace the finite batch submitted by that explicit action.
Concurrent manually initiated transfers are keyed independently. Sender receipt
state and receiver reassembly are capped at four sessions and evicted only by a
later explicit transfer/event; no cleanup timer is used.

Full and delta senders must be the current raid leader or an assistant. ACKs are
accepted only for a pending transfer from a roster member and must match its
transfer id, kind, revision, and wire hash.

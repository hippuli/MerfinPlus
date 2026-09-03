# MFPRA Raid Assignments contract

`MFPRA` is the stable Guild Manager/MerfinPlus assignment interchange. New
clipboard and addon-message envelopes are deliberately not format-versioned.
Existing `MFPRA1:` clipboard exports and `MFPRA1` addon messages remain
receive/import-only migration inputs; MerfinPlus never emits them.

## Clipboard envelope

`MFPRA:` + RFC 4648 padded Base64 of zlib-compressed canonical JSON.

Canonical JSON sorts object keys lexicographically and preserves array order.
The root `h` is the lowercase eight-digit Adler-32 of the canonical JSON with
`h` omitted. It is an integrity checksum, not a security signature.

Common root fields:

| Key | Meaning |
| --- | --- |
| `s` | Literal `MFPRA` |
| `k` | `F` full, `D` boss assignment delta, or `P` one Boss Plan delta |
| `r` | Positive integer revision |
| `h` | Semantic Adler-32 checksum |
| `x` | Literal `tbc` |
| `g` | Canonical raid-group id |

The root has no format-version field. Internal Boss Plan catalog and
SavedVariables migration numbers are private implementation details and do not
change the clipboard prefix.

### Full snapshot (`k=F`)

`a={c,rs,bs,pg?}` contains the complete assignment snapshot and optional T6
Pre-Boss Groups, and
`p={c:1,l:[...]}` contains all Boss Plans. Plans transport geometry and stable
asset IDs only; no texture, icon, or other binary asset bytes are embedded.

### Boss/widget delta (`k=D`)

`b` is the selected boss id. `a.bs` contains exactly that boss and `a.rs` its
raid identity. Boss Plans and unrelated bosses are forbidden.

### Boss Plan delta (`k=P`)

`b`, `i`, and `r` identify one boss, plan instance, and saved revision. `c=1`
and `p` contains exactly one catalog plan. The receiver replaces only the
matching plan in an existing full snapshot.

## Compact assignment model

- Raid: `{i,n,c}`: id, name, comp.
- Boss: `{i,n,q,t,s,tg?,ta?,tm?,bb?}`: id, name, raid id, Trash flag,
  sections, optional shared-Trash identity, and optional Bloodboil stack
  targets. When `bb` is absent the default is `[1,1,1]`; when present it is
  exactly three integer targets from `1` through `10`. Only
  `gurtogg_bloodboil` may contain `bb`; that valid configuration may use an
  empty `s` array before the first group member is assigned.
- Section: `{n,o,k,c,w}`: display name, source name, semantic category,
  context, and ordered rows.
- Context: `{t,r,b,p}`: type, raid name, boss name, phase.
- Pre-Boss Groups: `pg=[{i,g}]`: canonical `t6_*` boss id plus one through
  eight ordered groups. Every group contains exactly five name slots; empty
  slots are empty strings, and a non-empty player name may occur only once per
  boss. `pg` is optional for backward-compatible full imports and is forbidden
  in boss/widget deltas.
- Row: compact assignment/player/class/spec/target/marker/note fields. Icon
  tokens are `spell:<positive integer>` or
  `icon:<lowercase_wow_icon_token>`; URLs and binary data are forbidden.

Boss, section, row, and plan arrays are authoritative display order. Unknown
keys, invalid types, sparse arrays, non-finite geometry, unsupported asset IDs,
and limit violations are rejected before state mutation.

Boss Plans use the private MGMRA catalog model for validation. Supported emoji
elements carry one of the shared `symbol.emoji.*` IDs; their Unicode label is a
fallback only. Text fonts must be one of the shared runtime font tokens. Boss
elements support `bossFacingVisible`, `bossFacingArrowVisible`,
`bossFacingColor`, and `bossFacingRingWidth`.

## Addon transport

Addon prefix: `MFPRA`.

- `S|transferId|kind|revision|chunks|bytes|wireHash`
- `D|transferId|index|base64Slice`
- `E|transferId|wireHash`
- `A|transferId|kind|revision|wireHash|applied-or-stale|addonVersion`
- `N|transferId|kind|revision|wireHash|reasonCode`

Data slices are 180 bytes. `wireHash` is Adler-32 of the exact `MFPRA:`
envelope. Only explicit Import, Full Sync, boss/widget Send, and saved Boss Plan
Send actions initiate work. Import itself sends nothing.

Full and delta senders must be the current raid leader or an assistant. ACKs
must match a pending transfer id, kind, revision, and wire hash.

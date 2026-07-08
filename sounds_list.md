# Monk Experience — Sound Reference

All voice lines are `.ogg` and play through the **Dialog** channel. AFK music beds are `.mp3` (PlaySoundFile accepts both). Files live **flat** under `sounds/` (no per-category subfolders) and are referenced by filename in `MKE_main.lua`.

**System rules:**
- Global cooldown: 0s by default (configurable via `/vgm cd <seconds>`).
- `Force` sounds bypass the global cooldown and always cut whatever is currently playing.
- `Force` sounds cut each other; a non-force sound never cuts a force sound (it plays on top or is blocked by protect).
- `Protect` locks out non-force sounds for the given duration; force sounds still break through. Where a category's protect is described as **dynamic**, the value is the actual measured runtime of that specific file (+ a small buffer), stored as the 3rd value in that file's `{file, weight, protect}` entry — so the line always finishes playing before anything can cut it.
- `lowPriority` sounds (spammy fillers like Tiger Palm/Blackout Kick) never cut anything except another `lowPriority` sound — so they can't interrupt Leg Sweep, Interrupt, etc. — but two fillers still cut each other the way force sounds do. A normal (non-force, non-`lowPriority`) sound can still cut a `lowPriority` one.
- Last-played file in each category gets 10% weight in the random roll to reduce repeats.
- Single-file categories skip the weighting loop entirely.

---

## ⚠️ anyCombat default policy (assumed for this build)

There was no live user to confirm per-spell out-of-combat behavior, so this default was applied uniformly and can be adjusted per spell later:

**`anyCombat = true` (may play out of combat) ONLY for sounds that make sense outside combat by nature:**
mount, select, login, AFK start/end, death/revive ambient events, and pure movement/utility spells: Roll, Chi Torpedo, Tiger's Lust, Transcendence, Transcendence: Transfer, Zen Flight, Flying Serpent Kick / Slicing Winds, the Invoke celestials, both statue summons, Revival, Restoral, Resuscitate, and Reawaken (all out-of-combat rez abilities).

**Everything else is combat-only** (no `anyCombat` flag): all rotational damage/heal spells, cooldowns, defensives (Fortifying Brew, Life Cocoon, Thunder Focus Tea, Celestial Brew, Celestial Conduit, Zenith), interrupts, taunt, aggro, and leave-combat.

To make any combat-only spell also fire out of combat, add `anyCombat = true` to its entry in `SpellToSound`.

---

## Spell-ID verification status

**Verified via web search (Wowhead / warcraft.wiki.gg, Midnight 12.0.x):**

| Ability | Spell ID |
|---------|----------|
| Rushing Wind Kick | 467307 |
| Slicing Winds | 1217413 |
| Zenith | 1249625 |
| Zenith Stomp | 1272696 |
| Invoke Xuen, the White Tiger | 123904 |
| Invoke Yu'lon, the Jade Serpent | 322118 |
| Invoke Chi-Ji, the Red Crane | 325197 |
| Invoke Niuzao, the Black Ox | 132578 |
| Strike of the Windlord | 392983 |
| Whirling Dragon Punch | 152175 |
| Celestial Conduit | 443028 |
| Summon Jade Serpent Statue | 115313 |
| Grapple Weapon | 233759 |
| Reawaken | 212051 |
| Restoral | 388615 |

**NOT WOWHEAD-VERIFIED** — used from best current knowledge (long-stable Monk IDs; direct Wowhead page fetches returned HTTP 403 in earlier sessions, so these were not independently confirmed):

Tiger Palm 100780 · Blackout Kick 100784 · Rising Sun Kick 107428 · Spinning Crane Kick 101546 · Fists of Fury 113656 · Crackling Jade Lightning 117952 · Chi Burst 123986 · Touch of Death 322109 · Touch of Karma 122470 · Roll 109132 · Chi Torpedo 115008 · Tiger's Lust 116841 · Transcendence 101643 · Transcendence: Transfer 119996 · Zen Flight 125883 · Paralysis 115078 · Leg Sweep 119381 · Ring of Peace 116844 · Disable 116095 · Detox 218164 · Expel Harm 322101 · Provoke 115546 · Spear Hand Strike 116705 · Keg Smash 121253 · Breath of Fire 115181 · Purifying Brew 119582 · Fortifying Brew 115203 · Black Ox Brew 115399 · Exploding Keg 325153 · Renewing Mist 115151 · Soothing Mist 115175 · Mana Tea 197908 · Life Cocoon 116849 · Summon Black Ox Statue 115315 · Revival 115310 · Resuscitate 115178 · Thunder Focus Tea 116680 · Celestial Brew 322507 · Flying Serpent Kick 101545

---

## Probability Table

### Ambient Events

| Event | Category | Chance | Force | Protect | Out of Combat | Notes |
|-------|----------|--------|-------|---------|---------------|-------|
| Login / reload | LOGIN | 100% | ✓ | ~11.2s (dynamic) | ✓ | Once per hour, GetTime-gated; fires on PLAYER_ENTERING_WORLD |
| Self-target | SELECT | 100% | | — | ✓ | |
| Enter combat | AGGRO | 50% | | — | | |
| Leave combat | LEAVECOMBAT | 50% | | — | | Suppressed if dead |
| Player death | DEATH | 100% | ✓ | — | ✓ | Cuts everything |
| Player revive (ambient) | REVIVE | 100% | ✓ | per-file (dynamic) | ✓ | "Coming back to life" (canlanma → revived) |
| Mount up | MOUNT | 100% | | — | ✓ | prevMounted seeded on world entry |
| Go AFK | AFK_START | 100% | — | — | ✓ | Direct pcall'd play, handle stored; ~3.8s later a random AFK_MUSIC bed starts if still AFK |
| Return from AFK | AFK_END | 100% | ✓ | — | ✓ | AFK handle + music timer stopped first |

### Spell Sounds

| Spell | Spell ID | Category | Chance | Force | Protect | Out of Combat | Notes |
|-------|----------|----------|--------|-------|---------|---------------|-------|
| Tiger Palm | 100780 | TIGER_PALM | 25% | | — | | High-frequency filler, low prob, `lowPriority` (only cuts other fillers) |
| Blackout Kick | 100784 | BLACKOUT_KICK | 25% | | — | | High-frequency filler, low prob, `lowPriority` (only cuts other fillers) |
| Rising Sun Kick | 107428 | RISING_SUN_KICK | 100% | | — | | |
| Spinning Crane Kick | 101546 | SPINNING_CRANE_KICK | 25% | | — | | `lowPriority` |
| Fists of Fury | 113656 | FISTS_OF_FURY | 100% | | — | | `lowPriority`; single file (fistsoffury_1.ogg) |
| Crackling Jade Lightning | 117952 | CRACKLING_JADE | 100% | | — | | `lowPriority` |
| Chi Burst | 123986 | CHI_BURST | 100% | | — | | On cast start |
| Rushing Wind Kick | 467307 | RUSHING_WIND_KICK | 100% (30% on MW) | | ~1.5s (dynamic) | | Empowers Blackout Kick (WW); `lowPriority`; lower prob on Mistweaver via `probBySpec` |
| Touch of Death | 322109 | TOUCH_OF_DEATH | 100% | ✓ | per-file (dynamic) | | Execute signature |
| Touch of Karma | 122470 | TOUCH_OF_KARMA | 100% | | — | | |
| Strike of the Windlord | 392983 | STRIKES | 100% | | — | | sowl-wdp bundle |
| Whirling Dragon Punch | 152175 | STRIKES | 100% | | — | | sowl-wdp bundle |
| Zenith | 1249625 | ZENITH | 100% | ✓ | ~2.7s (dynamic) | | Shado-Pan capstone |
| Zenith Stomp | 1272696 | ZENITH_STOMP | 100% | | — | | May be an auto-proc — see notes |
| Celestial Conduit | 443028 | CELESTIAL_CONDUIT | 100% | ✓ | ~4.9s (dynamic) | | Conduit of the Celestials capstone |
| Flying Serpent Kick | 101545 | FLYING_SERPENT_KICK | 100% | | — | ✓ | Mobility |
| Slicing Winds | 1217413 | FLYING_SERPENT_KICK | 100% | | — | ✓ | Replaces/modifies FSK |
| Grapple Weapon | 233759 | GRAPPLE_WEAPON | 100% | | — | | PvP talent, disarm-like effect (all specs) |
| Invoke Xuen | 123904 | CELESTIAL_SUMMON | 100% | ✓ | ~2.1s (dynamic) | ✓ | |
| Invoke Yu'lon | 322118 | CELESTIAL_SUMMON | 100% | ✓ | ~2.1s (dynamic) | ✓ | |
| Invoke Chi-Ji | 325197 | CELESTIAL_SUMMON | 100% | ✓ | ~2.1s (dynamic) | ✓ | |
| Invoke Niuzao | 132578 | CELESTIAL_SUMMON | 100% | ✓ | ~2.1s (dynamic) | ✓ | |
| Roll | 109132 | ROLL | 100% | | — | ✓ | |
| Chi Torpedo | 115008 | CHI_TORPEDO | 100% | | — | ✓ | Separate slot from Roll |
| Tiger's Lust | 116841 | TIGERS_LUST | 100% | | — | ✓ | Single file (tigerslust_1.ogg) |
| Transcendence | 101643 | TRANSCENDENCE | 100% | | — | ✓ | |
| Transcendence: Transfer | 119996 | TRANS_TRANSFER | 100% | | — | ✓ | |
| Zen Flight | 125883 | ZEN_FLIGHT | 100% | | — | ✓ | |
| Paralysis | 115078 | PARALYSIS | 100% | | — | | |
| Leg Sweep | 119381 | LEG_SWEEP | 100% | | — | | Now 2 files (legsweep_1/2.ogg) |
| Ring of Peace | 116844 | RING_OF_PEACE | 100% | | — | | |
| Disable | 116095 | DISABLE | 100% | | — | | Sole file is disable_1.ogg |
| Detox | 218164 | DETOX | 100% | | — | | |
| Expel Harm | 322101 | EXPEL_HARM | 100% | | — | | |
| Provoke | 115546 | TAUNT | 100% | | — | | |
| Spear Hand Strike | 116705 | INTERRUPT | 100% | | — | | |
| Spear Hand Strike (miss) | 116705 | INTERRUPT_FAIL | — | | — | | On FAILED / INTERRUPTED; own 5s self-cooldown (`INTERRUPT_FAIL_CD`), independent of the protect-lock system; `lowPriority` |
| Keg Smash | 121253 | KEG_SMASH | 25% | | — | | `lowPriority` |
| Breath of Fire | 115181 | BREATH_OF_FIRE | 25% | | — | | `lowPriority` |
| Purifying Brew | 119582 | PURIFYING_BREW | 100% | | — | | |
| Fortifying Brew | 115203 | FORTIFYING_BREW | 100% | ✓ | ~2.5s (dynamic) | | Major defensive; single file (fortifyingbrew_1.ogg) |
| Black Ox Brew | 115399 | BLACK_OX_BREW | 100% | | — | | |
| Exploding Keg | 325153 | EXPLODING_KEG | 100% | | — | | |
| Renewing Mist | 115151 | RENEWING_MIST | 25% | | — | | `lowPriority` |
| Soothing Mist | 115175 | SOOTHING_MIST | 100% | | — | | Now 2 files (soothingmist_1/2.ogg) |
| Mana Tea | 197908 | MANA_TEA | 100% | | — | | |
| Life Cocoon | 116849 | LIFE_COCOON | 100% | ✓ | ~2.6s (dynamic) | | External defensive (chicacoon_1.ogg) |
| Summon Jade Serpent Statue | 115313 | STATUE_SUMMON | 100% | | — | ✓ | mw-bmstatue_1.ogg |
| Summon Black Ox Statue | 115315 | STATUE_SUMMON | 100% | | — | ✓ | mw-bmstatue_1.ogg |
| Revival | 115310 | REVIVAL_CAST | 100% | | — | ✓ | AoE raid-cooldown rez; on cast start; shares revival-restoral_1.ogg with Restoral |
| Restoral | 388615 | REVIVAL_CAST | 100% | | — | ✓ | Talent-exclusive alternative to Revival (same effect, no dispel, works while stunned); shares the same file/bucket as Revival |
| Resuscitate | 115178 | RESUSCITATE_CAST | 100% | | — | ✓ | Single-target out-of-combat rez; on cast start; cast lines (resuscitate_1..5.ogg) |
| Reawaken | 212051 | REAWAKEN | 100% | | — | ✓ | Mass out-of-combat rez (revives all dead party members within 100y); on cast start; single file (reawaken_1.ogg) |
| Thunder Focus Tea | 116680 | MAJOR_COOLDOWN | 100% | ✓ | ~2.6s (dynamic) | | Shared bundle file |
| Celestial Brew | 322507 | MAJOR_COOLDOWN | 100% | ✓ | ~2.6s (dynamic) | | Shared bundle file |

---

## Renames applied (per wow-voice-addon skill naming rules, historical + latest sound-pack refresh)

**Turkish → English translation (then camelCase), from the original sound pack:**
- `alancanlandırma.ogg` → (originally `revival.ogg`, now merged into `revival-restoral_1.ogg`) — "alan canlandırma" = "area revival" (Mistweaver **Revival**, 115310, AoE cooldown; now also covers **Restoral**, 388615).
- `canlandırma_1..5.ogg` → now `resuscitate_1..5.ogg` (previously `revive_1..5.ogg`) — "canlandırma" = "revival/resurrection" (voice lines for casting **Resuscitate**, 115178, single-target out-of-combat rez — distinct spell from Revival above).
- `canlanma_1..4.ogg` → now `revived_1..3.ogg` (previously `revived_1..4.ogg`; the 4th file was dropped in the latest sound-pack refresh) — "canlanma" = "coming back to life" (ambient REVIVE, distinct from the spell casts above).

**Latest sound-pack refresh — normalized to `_N` suffix convention:**
Nearly every previously-bare filename (e.g. `tigerpalm.ogg`, `paralysis.ogg`, `roll.ogg`) was renamed to include a numeric suffix (`tigerpalm_1.ogg`, `paralysis_1.ogg`, `roll_1.ogg`, etc.) for consistency with the already-numbered categories. Where the category is still single-file, only the filename changed — the mapping/logic did not.

**Typo/name corrections in the refresh:**
- `fistoffury_1/2.ogg` (2 files) → `fistsoffury_1.ogg` (1 file, corrected "Fists" spelling, merged to single file)
- `risingsunkickcrit.ogg` → `risingsunkick_1.ogg`
- `disable_2.ogg` → `disable_1.ogg` (still the sole DISABLE file, renumbered)
- `zenithstomp.ogg` → split into **two** files, `zenitstomp_1.ogg` (note: missing the "h", likely a typo in the source pack) and `zenithstomp_2.ogg` — both pooled under ZENITH_STOMP since they clearly belong to the same line

**Files removed in the refresh (no longer referenced):**
- `disarm.ogg` — previously folded into INTERRUPT as a fallback because no real Monk disarm existed; superseded by the new real **Grapple Weapon** (233759, `grappleweapon_1.ogg`) ability/category.
- `lighterthanair.ogg` — previously folded into ROLL as a fallback for the passive talent; removed, ROLL is single-file again (`roll_1.ogg`).
- `tigerslust_2.ogg`, `chiji-yulon-blackox-whitetiger_2.ogg`, `fortifyingbrew_2/3.ogg`, `mount_2.ogg`, `aggro_7/8.ogg`, `death_3/4/5.ogg` — pool sizes shrank for these categories; no replacement needed.

**New files added in the refresh (new spells/lines):**
- `grappleweapon_1.ogg` — new **GRAPPLE_WEAPON** category, spell 233759 (Grapple Weapon, PvP talent, disarm-like, all specs).
- `reawaken_1.ogg` — new **REAWAKEN** category, spell 212051 (Reawaken, mass out-of-combat rez).
- `aggro_4.ogg` — filled the old numbering gap; AGGRO pool is now aggro_1..6.
- `legsweep_2.ogg`, `soothingmist_2.ogg` — added as second files to previously single-file LEG_SWEEP / SOOTHING_MIST categories.

**English spelling fix (+ camelCase compound), from earlier sessions:**
- `transendence.ogg` → `transcendence_1.ogg`
- `transendenceteleport.ogg` → `transcendenceTeleport_1.ogg`

**Left unchanged — hyphenated multi-ability-merge filenames** (mirrors BetterHunterExperience precedent of keeping hyphens between merged ability-name segments rather than forcing pure camelCase), now with `_1` suffix:
- `flyingserpentkick-slicingwinds_1.ogg`
- `chiji-yulon-blackox-whitetiger_1.ogg` (now single-file; `_2` was removed)
- `thunderfocustea-celestialinfusion-celestialbrew_1.ogg`
- `mw-bmstatue_1.ogg`, `sowl-wdp_1.ogg`

All other numbered files (select_N, taunt_N, leavecombat_N, etc.) already matched the reference convention and were left as-is.

---

## REVIVE vs REVIVAL_CAST vs RESUSCITATE_CAST vs REAWAKEN — do not conflate

Four distinct rez-related sound buckets, four distinct triggers:

- **REVIVE** (ambient, `force = true`) — `revived_1..3.ogg`. Fires from the OnUpdate poll when the player transitions from dead to alive (`UnitIsDeadOrGhost` false after being true). This is "your character coming back to life," not a spell cast.
- **REVIVAL_CAST** (spells 115310 Revival + 388615 Restoral) — `revival-restoral_1.ogg` (single shared file). Fires on `UNIT_SPELLCAST_START`. Revival and Restoral are an exclusive-choice talent pair with the same functional role (AoE raid-cooldown rez), so they share one bucket.
- **RESUSCITATE_CAST** (spell 115178, Resuscitate) — `resuscitate_1..5.ogg`. Fires on `UNIT_SPELLCAST_START` for the Mistweaver **Resuscitate** single-target, out-of-combat rez.
- **REAWAKEN** (spell 212051, Reawaken) — `reawaken_1.ogg`. Fires on `UNIT_SPELLCAST_START` for the Mistweaver **Reawaken** mass out-of-combat rez (all dead party members within 100y). Distinct from Resuscitate (single-target) and Revival/Restoral (in-combat-capable raid cooldown).

---

## Dynamic protect — categories using measured file runtime instead of a fixed number

Per the latest pass, every category that previously used a flat `protect = N` cooldown-style lock now uses the **actual measured duration** of its sound file (+ ~0.2s buffer) as the 3rd value in its `MKE_Sounds` entry, so the line always finishes before anything can cut it. `cfg.protect` was removed from the corresponding `SpellToSound` entries (the per-file value from `RollSound` takes precedence in `PlayRandom`).

| Category | File(s) | Dynamic protect |
|----------|---------|-----------------|
| LOGIN | login_1.ogg | ~11.2s |
| REVIVE | revived_1/2/3.ogg | 1.6s / 4.6s / 3.1s |
| TOUCH_OF_DEATH | touchofdeath_1/2/3.ogg | 1.5s / 1.4s / 3.8s |
| RUSHING_WIND_KICK | rushingwindkick_1.ogg | ~1.5s |
| ZENITH | zenith_1.ogg | ~2.7s |
| CELESTIAL_CONDUIT | celestialconduit_1.ogg | ~4.9s |
| CELESTIAL_SUMMON | chiji-yulon-blackox-whitetiger_1.ogg | ~2.1s |
| FORTIFYING_BREW | fortifyingbrew_1.ogg | ~2.5s |
| LIFE_COCOON | chicacoon_1.ogg | ~2.6s |
| MAJOR_COOLDOWN | thunderfocustea-celestialinfusion-celestialbrew_1.ogg | ~2.6s |

Categories NOT converted (no protect was ever set for them): FISTS_OF_FURY (now `lowPriority` instead), INTERRUPT_FAIL (uses its own independent 5s self-cooldown, not the protect-lock system).

---

## Ambiguous-filename judgment calls

| File | Decision | Confidence | Wowhead-verified |
|------|----------|-----------|------------------|
| `mw-bmstatue_1.ogg` | STATUE_SUMMON category, mapped to **both** Summon Jade Serpent Statue (115313, MW) and Summon Black Ox Statue (115315, BM). "mw" = Mistweaver, "bm" = Brewmaster — one file covers both spec statues. | High | Jade Serpent Statue verified; Black Ox Statue from knowledge |
| `sowl-wdp_1.ogg` | STRIKES category, mapped to **Strike of the Windlord** (392983, "SotWL"≈"sowl") + **Whirling Dragon Punch** (152175, "WDP"). Abbreviations decoded to two real WW abilities — so this is fully mapped, not left orphaned. | Medium-High | Both IDs verified |
| `thunderfocustea-celestialinfusion-celestialbrew_1.ogg` | ONE shared MAJOR_COOLDOWN category, mapped to **Thunder Focus Tea** (116680) and **Celestial Brew** (322507). "Celestial Infusion" could not be confirmed as a current talent and was treated as deprecated / skipped — no spell ID mapped for it. | Medium | TFT/Celestial Brew from knowledge; Celestial Infusion unconfirmed → skipped |
| `celestialconduit_1.ogg` | Its **own** CELESTIAL_CONDUIT category (443028), kept separate from the major-cooldown bundle, since it is the distinct Conduit of the Celestials capstone. Force major cooldown, dynamic protect. | High | Verified |
| `chiji-yulon-blackox-whitetiger_1.ogg` | ONE shared CELESTIAL_SUMMON category, multi-mapped to all four Invoke celestials (Xuen 123904, Yu'lon 322118, Chi-Ji 325197, Niuzao 132578). Force major cooldowns, dynamic protect. Now single-file (`_2` removed in the refresh). | High | All four verified |
| `zenith_1.ogg` | ZENITH category (1249625), force major cooldown, dynamic protect. | High | Verified |
| `zenitstomp_1.ogg` + `zenithstomp_2.ogg` | Both pooled into ZENITH_STOMP (1272696) — the source pack ships one correctly-spelled and one typo'd filename for what is clearly the same line/category. Zenith Stomp is likely the delayed AoE *proc* from Zenith and may not raise `UNIT_SPELLCAST_SUCCEEDED` from the player; if it never fires, the Zenith line already covers the cooldown. | Medium (IDs verified; trigger uncertain) | ID verified; cast-event behavior unverified |
| `chicacoon_1.ogg` | LIFE_COCOON category (116849). "chi cacoon" ≈ "Life Cocoon", the Mistweaver external defensive. Force, dynamic protect. | Medium-High | From knowledge |
| `grappleweapon_1.ogg` | New GRAPPLE_WEAPON category (233759). Grapple Weapon is a PvP talent (all specs) with a disarm-like effect — this replaces the old `disarm.ogg` fallback now that a real matching ability/file exists. | High | Verified |
| `reawaken_1.ogg` | New REAWAKEN category (212051). Mass out-of-combat rez, distinct from Resuscitate (single-target) and Revival/Restoral (raid CD). On cast start, anyCombat (out-of-combat only spell). | High | Verified |
| `revival-restoral_1.ogg` | REVIVAL_CAST category, now shared between Revival (115310) and Restoral (388615) — an exclusive-choice talent pair with the same functional role, so one file covers both, same pattern as the MAJOR_COOLDOWN bundle. | Medium-High | Restoral ID verified; shared-file judgment call |
| `rushingwindkick_1.ogg` | RUSHING_WIND_KICK category (467307), a current WW talent that empowers Blackout Kick. `lowPriority`, dynamic protect, lower prob on Mistweaver via `probBySpec`. | High | Verified |
| `flyingserpentkick-slicingwinds_1.ogg` | FLYING_SERPENT_KICK category, mapped to both Flying Serpent Kick (101545) and Slicing Winds (1217413), a current WW talent. anyCombat (mobility). | Medium-High | Slicing Winds verified; FSK from knowledge |
| `risingsunkick_1.ogg` | Sole file for RISING_SUN_KICK (107428); renamed from `risingsunkickcrit.ogg` in the refresh (no longer crit-specific by name, but still the entire pool). | High | ID from knowledge |
| `disable_1.ogg` | Sole file for DISABLE (116095); renamed from `disable_2.ogg` in the refresh. | Medium | From knowledge |
| `roll_1.ogg` vs `chitorpedo_1.ogg` | Kept as **separate** categories (Roll 109132, Chi Torpedo 115008). Although they share a talent slot, each has a distinct spell ID and only one is active per build, so separate entries are cleaner and never double-fire. | High | IDs from knowledge |
| `zenflight_1.ogg` | ZEN_FLIGHT category (125883), mapped as a discrete cast (anyCombat). Kept out of the MOUNT ambient pool since it is an explicit cast, not a mount toggle. | Medium | From knowledge |
| `afkstart_1.ogg` + `afkmusic_1..5.mp3` | AFK_START is stinger-only (single file), always plays first on going AFK. ~3.8s later (its measured runtime + buffer), if still AFK, a random file from AFK_MUSIC (the 5 `.mp3` beds) plays automatically. Timer is cancelled and any playing AFK sound stopped on return from AFK. `.mp3` files are referenced as-is (no format conversion). | Medium (design choice) | N/A |

---

## Notes on gaps

- No plain `risingsunkick` crit/non-crit split exists — `risingsunkick_1.ogg` is the entire RISING_SUN_KICK pool.
- `zenitstomp_1.ogg` (typo, missing "h") coexists with `zenithstomp_2.ogg` — both intentionally pooled together, not a bug.

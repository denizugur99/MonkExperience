# Monk Experience — Sound Reference

All voice lines are `.ogg` and play through the **Dialog** channel. AFK music beds are `.mp3` (PlaySoundFile accepts both). Files live **flat** under `sounds/` (no per-category subfolders) and are referenced by filename in `MKE_main.lua`.

**System rules:**
- Global cooldown: 0s by default (configurable via `/mke cd <seconds>`).
- `Force` sounds bypass the global cooldown and always cut whatever is currently playing.
- `Force` sounds cut each other; a non-force sound never cuts a force sound (it plays on top or is blocked by protect).
- `Protect` locks out non-force sounds for the given duration; force sounds still break through.
- Last-played file in each category gets 10% weight in the random roll to reduce repeats.
- Single-file categories skip the weighting loop entirely.

---

## ⚠️ anyCombat default policy (assumed for this build)

There was no live user to confirm per-spell out-of-combat behavior, so this default was applied uniformly and can be adjusted per spell later:

**`anyCombat = true` (may play out of combat) ONLY for sounds that make sense outside combat by nature:**
mount, select, login, AFK start/end, death/revive ambient events, and pure movement/utility spells: Roll, Chi Torpedo, Tiger's Lust, Transcendence, Transcendence: Transfer, Zen Flight, Flying Serpent Kick / Slicing Winds, the Invoke celestials, and both statue summons.

**Everything else is combat-only** (no `anyCombat` flag): all rotational damage/heal spells, cooldowns, defensives (Fortifying Brew, Life Cocoon, Revival, Thunder Focus Tea, Celestial Brew, Celestial Conduit, Zenith), interrupts, taunt, aggro, and leave-combat.

To make any combat-only spell also fire out of combat, add `anyCombat = true` to its entry in `SpellToSound`.

---

## Spell-ID verification status

**Verified this session via web search (Wowhead / warcraft.wiki.gg, Midnight 12.0.x):**

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

**NOT WOWHEAD-VERIFIED** — used from best current knowledge (long-stable Monk IDs; direct Wowhead page fetches returned HTTP 403, so these were not independently confirmed this session). Verify in-game with `/mke debug` if any line fails to fire:

Tiger Palm 100780 · Blackout Kick 100784 · Rising Sun Kick 107428 · Spinning Crane Kick 101546 · Fists of Fury 113656 · Crackling Jade Lightning 117952 · Chi Burst 123986 · Touch of Death 322109 · Touch of Karma 122470 · Roll 109132 · Chi Torpedo 115008 · Tiger's Lust 116841 · Transcendence 101643 · Transcendence: Transfer 119996 · Zen Flight 125883 · Paralysis 115078 · Leg Sweep 119381 · Ring of Peace 116844 · Disable 116095 · Detox 218164 · Expel Harm 322101 · Provoke 115546 · Spear Hand Strike 116705 · Keg Smash 121253 · Breath of Fire 115181 · Purifying Brew 119582 · Fortifying Brew 115203 · Black Ox Brew 115399 · Exploding Keg 325153 · Renewing Mist 115151 · Soothing Mist 115175 · Mana Tea 197908 · Life Cocoon 116849 · Summon Black Ox Statue 115315 · Revival 115310 · Thunder Focus Tea 116680 · Celestial Brew 322507 · Flying Serpent Kick 101545

---

## Probability Table

### Ambient Events

| Event | Category | Chance | Force | Protect | Out of Combat | Notes |
|-------|----------|--------|-------|---------|---------------|-------|
| Login / reload | LOGIN | 100% | ✓ | 10s | ✓ | Once per hour, GetTime-gated; fires on PLAYER_ENTERING_WORLD |
| Self-target | SELECT | 100% | | — | ✓ | |
| Enter combat | AGGRO | 50% | | — | | |
| Leave combat | LEAVECOMBAT | 50% | | — | | Suppressed if dead |
| Player death | DEATH | 100% | ✓ | — | ✓ | Cuts everything |
| Player revive (ambient) | REVIVE | 100% | ✓ | — | ✓ | "Coming back to life" (canlanma → revived) |
| Mount up | MOUNT | 100% | | — | ✓ | prevMounted seeded on world entry |
| Go AFK | AFK_START | 100% | — | — | ✓ | Direct pcall'd play, handle stored |
| Return from AFK | AFK_END | 100% | ✓ | — | ✓ | AFK handle stopped first |

### Spell Sounds

| Spell | Spell ID | Category | Chance | Force | Protect | Out of Combat | Notes |
|-------|----------|----------|--------|-------|---------|---------------|-------|
| Tiger Palm | 100780 | TIGER_PALM | 25% | | — | | High-frequency filler, low prob |
| Blackout Kick | 100784 | BLACKOUT_KICK | 25% | | — | | High-frequency filler, low prob |
| Rising Sun Kick | 107428 | RISING_SUN_KICK | 100% | | — | | Sole file is the crit line |
| Spinning Crane Kick | 101546 | SPINNING_CRANE_KICK | 40% | | — | | |
| Fists of Fury | 113656 | FISTS_OF_FURY | 100% | | 2s | | Channel; short protect |
| Crackling Jade Lightning | 117952 | CRACKLING_JADE | 50% | | — | | |
| Chi Burst | 123986 | CHI_BURST | 60% | | — | | |
| Rushing Wind Kick | 467307 | RUSHING_WIND_KICK | 100% | | — | | Empowers Blackout Kick (WW) |
| Touch of Death | 322109 | TOUCH_OF_DEATH | 100% | ✓ | 3s | | Execute signature |
| Touch of Karma | 122470 | TOUCH_OF_KARMA | 100% | | — | | |
| Strike of the Windlord | 392983 | STRIKES | 100% | | — | | sowl-wdp bundle |
| Whirling Dragon Punch | 152175 | STRIKES | 100% | | — | | sowl-wdp bundle |
| Zenith | 1249625 | ZENITH | 100% | ✓ | 3s | | Shado-Pan capstone |
| Zenith Stomp | 1272696 | ZENITH_STOMP | 100% | | — | | May be an auto-proc — see notes |
| Celestial Conduit | 443028 | CELESTIAL_CONDUIT | 100% | ✓ | 3s | | Conduit of the Celestials capstone |
| Flying Serpent Kick | 101545 | FLYING_SERPENT_KICK | 100% | | — | ✓ | Mobility |
| Slicing Winds | 1217413 | FLYING_SERPENT_KICK | 100% | | — | ✓ | Replaces/modifies FSK |
| Invoke Xuen | 123904 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ | |
| Invoke Yu'lon | 322118 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ | |
| Invoke Chi-Ji | 325197 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ | |
| Invoke Niuzao | 132578 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ | |
| Roll | 109132 | ROLL | 50% | | — | ✓ | Pool includes lighterthanair.ogg |
| Chi Torpedo | 115008 | CHI_TORPEDO | 60% | | — | ✓ | Separate slot from Roll |
| Tiger's Lust | 116841 | TIGERS_LUST | 100% | | — | ✓ | |
| Transcendence | 101643 | TRANSCENDENCE | 100% | | — | ✓ | |
| Transcendence: Transfer | 119996 | TRANS_TRANSFER | 100% | | — | ✓ | |
| Zen Flight | 125883 | ZEN_FLIGHT | 100% | | — | ✓ | |
| Paralysis | 115078 | PARALYSIS | 100% | | — | | |
| Leg Sweep | 119381 | LEG_SWEEP | 100% | | — | | |
| Ring of Peace | 116844 | RING_OF_PEACE | 100% | | — | | |
| Disable | 116095 | DISABLE | 50% | | — | | Sole file is disable_2.ogg |
| Detox | 218164 | DETOX | 100% | | — | | |
| Expel Harm | 322101 | EXPEL_HARM | 30% | | — | | High-frequency, low prob |
| Provoke | 115546 | TAUNT | 100% | | — | | |
| Spear Hand Strike | 116705 | INTERRUPT | 100% | | — | | disarm.ogg folded into pool |
| Spear Hand Strike (miss) | 116705 | INTERRUPT_FAIL | 100% | | — | | On FAILED / INTERRUPTED |
| Keg Smash | 121253 | KEG_SMASH | 40% | | — | | |
| Breath of Fire | 115181 | BREATH_OF_FIRE | 60% | | — | | |
| Purifying Brew | 119582 | PURIFYING_BREW | 50% | | — | | |
| Fortifying Brew | 115203 | FORTIFYING_BREW | 100% | ✓ | 3s | | Major defensive |
| Black Ox Brew | 115399 | BLACK_OX_BREW | 100% | | — | | |
| Exploding Keg | 325153 | EXPLODING_KEG | 100% | | — | | |
| Renewing Mist | 115151 | RENEWING_MIST | 40% | | — | | |
| Soothing Mist | 115175 | SOOTHING_MIST | 40% | | — | | |
| Mana Tea | 197908 | MANA_TEA | 60% | | — | | |
| Life Cocoon | 116849 | LIFE_COCOON | 100% | ✓ | 3s | | External defensive (chicacoon.ogg) |
| Summon Jade Serpent Statue | 115313 | STATUE_SUMMON | 100% | | — | ✓ | mw-bmstatue.ogg |
| Summon Black Ox Statue | 115315 | STATUE_SUMMON | 100% | | — | ✓ | mw-bmstatue.ogg |
| Revival | 115310 | REVIVAL_CAST | 100% | | — | ✓ | AoE raid-cooldown rez; on cast start; cast lines (revival.ogg only) |
| Resuscitate | 115178 | RESUSCITATE_CAST | 100% | | — | ✓ | Single-target out-of-combat rez; on cast start; cast lines (revive_1..5.ogg) |
| Thunder Focus Tea | 116680 | MAJOR_COOLDOWN | 100% | ✓ | 3s | | Shared bundle file |
| Celestial Brew | 322507 | MAJOR_COOLDOWN | 100% | ✓ | 3s | | Shared bundle file |

---

## Renames applied (per wow-voice-addon skill naming rules)

**Turkish → English translation (then camelCase):**
- `alancanlandırma.ogg` → `revival.ogg` — "alan canlandırma" = "area revival" (Mistweaver **Revival**, 115310, AoE cooldown).
- `canlandırma_1..5.ogg` → `revive_1..5.ogg` — "canlandırma" = "revival/resurrection" (voice lines for casting **Resuscitate**, 115178, single-target out-of-combat rez — distinct spell from Revival above).
- `canlanma_1..4.ogg` → `revived_1..4.ogg` — "canlanma" = "coming back to life" (ambient REVIVE, distinct from the spell cast above).

**Typo consolidation:**
- `fortyfyingbrew_1.ogg` → `fortifyingbrew_1.ogg`
- `fortyfyingbrew_2.ogg` → `fortifyingbrew_2.ogg`
- (merged with existing `fortifyingbrew_3.ogg` into one 3-file FORTIFYING_BREW category)

**English spelling fix (+ camelCase compound):**
- `transendence.ogg` → `transcendence.ogg`
- `transendenceteleport.ogg` → `transcendenceTeleport.ogg`

**Left unchanged — hyphenated multi-ability-merge filenames** (mirrors BetterHunterExperience precedent of keeping hyphens between merged ability-name segments rather than forcing pure camelCase):
- `flyingserpentkick-slicingwinds.ogg`
- `chiji-yulon-blackox-whitetiger_1.ogg`, `chiji-yulon-blackox-whitetiger_2.ogg`
- `thunderfocustea-celestialinfusion-celestialbrew.ogg`
- `mw-bmstatue.ogg`, `sowl-wdp.ogg`

All other numbered files (aggro_N, death_N, mount_N, select_N, taunt_N, etc.) already matched the reference convention (underscore before number) and were left as-is.

---

## REVIVE vs REVIVAL_CAST vs RESUSCITATE_CAST — do not conflate

- **REVIVE** (ambient, `force = true`) — `revived_1..4.ogg`. Fires from the OnUpdate poll when the player transitions from dead to alive (`UnitIsDeadOrGhost` false after being true). This is "your character coming back to life."
- **REVIVAL_CAST** (spell 115310, Revival) — `revival.ogg` only. Fires on `UNIT_SPELLCAST_START` for the Mistweaver **Revival** AoE raid-cooldown rez. "alan canlandırma" = area revival.
- **RESUSCITATE_CAST** (spell 115178, Resuscitate) — `revive_1..5.ogg`. Fires on `UNIT_SPELLCAST_START` for the Mistweaver **Resuscitate** single-target, out-of-combat rez. These generic "canlandırma" lines (no "alan"/area qualifier) were previously lumped into REVIVAL_CAST alongside revival.ogg with no spell mapping of their own — split out so Revival and Resuscitate no longer share a bucket.

---

## Ambiguous-filename judgment calls

| File | Decision | Confidence | Wowhead-verified |
|------|----------|-----------|------------------|
| `mw-bmstatue.ogg` | STATUE_SUMMON category, mapped to **both** Summon Jade Serpent Statue (115313, MW) and Summon Black Ox Statue (115315, BM). "mw" = Mistweaver, "bm" = Brewmaster — one file covers both spec statues. | High | Jade Serpent Statue verified; Black Ox Statue from knowledge |
| `sowl-wdp.ogg` | STRIKES category, mapped to **Strike of the Windlord** (392983, "SotWL"≈"sowl") + **Whirling Dragon Punch** (152175, "WDP"). Abbreviations decoded to two real WW abilities — so this is fully mapped, not left orphaned. | Medium-High | Both IDs verified this session |
| `thunderfocustea-celestialinfusion-celestialbrew.ogg` | ONE shared MAJOR_COOLDOWN category, mapped to **Thunder Focus Tea** (116680) and **Celestial Brew** (322507). "Celestial Infusion" could not be confirmed as a current talent and was treated as deprecated / skipped — no spell ID mapped for it. | Medium | TFT/Celestial Brew from knowledge; Celestial Infusion unconfirmed → skipped |
| `celestialconduit.ogg` | Its **own** CELESTIAL_CONDUIT category (443028), kept separate from the major-cooldown bundle, since it is the distinct Conduit of the Celestials capstone. Force major cooldown. | High | Verified this session |
| `chiji-yulon-blackox-whitetiger_1/2.ogg` | ONE shared CELESTIAL_SUMMON category, multi-mapped to all four Invoke celestials (Xuen 123904, Yu'lon 322118, Chi-Ji 325197, Niuzao 132578). Force major cooldowns. | High | All four verified this session |
| `zenith.ogg` | ZENITH category (1249625), force major cooldown. | High | Verified this session |
| `zenithstomp.ogg` | Separate ZENITH_STOMP category (1272696). Zenith Stomp is likely the delayed AoE *proc* from Zenith and may not raise `UNIT_SPELLCAST_SUCCEEDED` from the player. If it never fires, the Zenith line already covers the cooldown; if desired, merge zenithstomp.ogg into the ZENITH pool. | Medium (ID verified; trigger uncertain) | ID verified; cast-event behavior unverified |
| `chicacoon.ogg` | LIFE_COCOON category (116849). "chi cacoon" ≈ "Life Cocoon", the Mistweaver external defensive. Force. | Medium-High | From knowledge |
| `disarm.ogg` | No current Monk disarm ability exists. Folded into the INTERRUPT pool (Spear Hand Strike) as a flavor line so it stays referenced and playable. | Medium (deliberate fallback) | N/A (no such spell) |
| `lighterthanair.ogg` | "Lighter Than Air" is a passive talent (no cast event), so it cannot trigger on its own. Folded into the ROLL pool (movement-related) so it plays on Roll. | Medium (deliberate fallback) | N/A (passive) |
| `rushingwindkick.ogg` | RUSHING_WIND_KICK category (467307), a current WW talent that empowers Blackout Kick. | High | Verified this session |
| `flyingserpentkick-slicingwinds.ogg` | FLYING_SERPENT_KICK category, mapped to both Flying Serpent Kick (101545) and Slicing Winds (1217413), a current WW talent. anyCombat (mobility). | Medium-High | Slicing Winds verified; FSK from knowledge |
| `risingsunkickcrit.ogg` | Sole file for RISING_SUN_KICK (107428); the crit-specific line is the entire pool. | High | ID from knowledge |
| `disable_2.ogg` | Sole file for DISABLE (116095); the missing disable_1 is a gap, not an error. | Medium | From knowledge |
| `roll.ogg` vs `chitorpedo.ogg` | Kept as **separate** categories (Roll 109132, Chi Torpedo 115008). Although they share a talent slot, each has a distinct spell ID and only one is active per build, so separate entries are cleaner and never double-fire. | High | IDs from knowledge |
| `zenflight.ogg` | ZEN_FLIGHT category (125883), mapped as a discrete cast (anyCombat). Kept out of the MOUNT ambient pool since it is an explicit cast, not a mount toggle. | Medium | From knowledge |
| `afkstart.ogg` + `afkmusic_1..5.mp3` | ALL SIX pooled into AFK_START. Judgment: rather than treat afkstart.ogg as a fixed stinger and afkmusic as the bed, the AFK helper rolls one random file from the pool each time you go AFK (variety), stores the handle, and stops it on return. `.mp3` files are referenced as-is (no format conversion). | Medium (design choice) | N/A |

---

## Notes on missing files / gaps

- `aggro_4.ogg` is absent — a gap in the numbering, not an error. Only the existing 7 aggro files are referenced.
- `disable_1.ogg` is absent — `disable_2.ogg` is the sole DISABLE file.
- No plain `risingsunkick.ogg` exists — only the crit variant, used as the whole category.

# Monk Experience

A Monk class voice pack addon for World of Warcraft Midnight (12.x). Plays character voice lines in response to spells, cooldowns, and ambient game events across all three Monk specializations — Windwalker, Brewmaster, and Mistweaver.

---

## Features

- **All three specs covered** — Windwalker, Brewmaster, and Mistweaver each have spec-specific spell triggers in addition to shared abilities.
- **Ambient event reactions** — voice lines play on entering and leaving combat, mounting up, death, revive, going AFK and returning, logging in, and targeting yourself.
- **Sound variety** — large randomized pools for high-frequency events (13 self-target lines, 12 mount lines, 7 taunt lines) with a repeat-penalty system so the same line rarely plays back-to-back.
- **Force/protect system** — major cooldowns and life-saving abilities cut through ambient sounds and lock out weaker reactions during their protect window.
- **Spear Hand Strike miss line** — a distinct voice line plays when your interrupt fails or is interrupted.
- **AFK music** — a randomized AFK stinger / music bed plays while you are away and stops the moment you return.
- **No aura tracking** — uses only cast events and reliable Midnight-era APIs; no broken buff/aura calls.

---

## Installation

1. Download or clone the repository.
2. Copy the `MonkExperience` folder into your WoW addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\MonkExperience\
   ```
3. The folder name, `.toc` filename, and internal references must all be `MonkExperience` — do not rename the folder.
4. Launch WoW and enable the addon in the AddOns list on the character select screen.

---

## Recommended Sound Settings

All voice lines play on the **Dialog** audio channel. For the best experience:

| Channel | Volume |
|---------|--------|
| Dialog  | 100%   |
| Music   | 10–30% |
| SFX     | 10–30% |
| Ambient | 10–30% |

1. Open **System > Sound**.
2. Make sure **Enable Sound** is checked.
3. Set the **Dialog** channel volume to a comfortable level (default is often low).
4. If voice lines are inaudible during combat, try raising **Dialog** and lowering **Effects** slightly.

The addon does not touch Music, Ambience, or Effects channels.

---

## Commands

| Command | Description |
|---------|-------------|
| `/mke on` | Enable sounds |
| `/mke off` | Disable sounds |
| `/mke debug` | Toggle debug output |
| `/mke cd <seconds>` | Set global cooldown between sounds (default: 0s) |

---

## How It Works

**Ambient events** are detected by polling every 0.2 seconds (death, combat, mount, AFK, self-target) or via WoW events (login).

**Spell sounds** are detected via `UNIT_SPELLCAST_SUCCEEDED` (instant / off-GCD spells) or `UNIT_SPELLCAST_START` (cast-time spells marked with `onCastStart`). Interrupt-miss lines fire on `UNIT_SPELLCAST_FAILED` / `UNIT_SPELLCAST_INTERRUPTED`.

**Global cooldown:** A configurable cooldown prevents multiple sounds from stacking. Force sounds bypass the global cooldown and always cut whatever is currently playing. Force sounds cut each other; non-force sounds never stop a force sound (they either play on top or are blocked by the protect window). A `protect` duration locks out non-force sounds after a force sound plays.

**Repeat penalty:** The last-played file in each category receives 10% of its normal weight in the random roll, reducing back-to-back repeats.

---

## Triggered Sounds

### Ambient Events

| Event | Category | Pool Size | Force | Notes |
|-------|----------|-----------|-------|-------|
| Login / reload | LOGIN | 1 | Yes | Once per hour; 10s protect |
| Self-target | SELECT | 13 | No | |
| Enter combat | AGGRO | 7 | No | 50% trigger chance |
| Leave combat | LEAVECOMBAT | 5 | No | 50% chance; suppressed if dead |
| Player death | DEATH | 5 | Yes | Cuts all current sounds |
| Player revive | REVIVE | 4 | Yes | Coming back to life |
| Mount up | MOUNT | 12 | No | Suppressed on world entry |
| Go AFK | AFK_START | 6 | — | Random stinger/music; stopped on return |
| Return from AFK | AFK_END | 1 | Yes | AFK sound stopped first |

### Spell Sounds

| Spell | Spell ID | Category | Chance | Force | Protect | Out of Combat |
|-------|----------|----------|--------|-------|---------|---------------|
| Tiger Palm | 100780 | TIGER_PALM | 25% | | — | |
| Blackout Kick | 100784 | BLACKOUT_KICK | 25% | | — | |
| Rising Sun Kick | 107428 | RISING_SUN_KICK | 100% | | — | |
| Spinning Crane Kick | 101546 | SPINNING_CRANE_KICK | 40% | | — | |
| Fists of Fury | 113656 | FISTS_OF_FURY | 100% | | 2s | |
| Crackling Jade Lightning | 117952 | CRACKLING_JADE | 50% | | — | |
| Chi Burst | 123986 | CHI_BURST | 60% | | — | |
| Rushing Wind Kick | 467307 | RUSHING_WIND_KICK | 100% | | — | |
| Touch of Death | 322109 | TOUCH_OF_DEATH | 100% | ✓ | 3s | |
| Touch of Karma | 122470 | TOUCH_OF_KARMA | 100% | | — | |
| Strike of the Windlord | 392983 | STRIKES | 100% | | — | |
| Whirling Dragon Punch | 152175 | STRIKES | 100% | | — | |
| Zenith | 1249625 | ZENITH | 100% | ✓ | 3s | |
| Zenith Stomp ⁴ | 1272696 | ZENITH_STOMP | 100% | | — | |
| Celestial Conduit | 443028 | CELESTIAL_CONDUIT | 100% | ✓ | 3s | |
| Flying Serpent Kick | 101545 | FLYING_SERPENT_KICK | 100% | | — | ✓ |
| Slicing Winds | 1217413 | FLYING_SERPENT_KICK | 100% | | — | ✓ |
| Invoke Xuen | 123904 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ |
| Invoke Yu'lon | 322118 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ |
| Invoke Chi-Ji | 325197 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ |
| Invoke Niuzao | 132578 | CELESTIAL_SUMMON | 100% | ✓ | 3s | ✓ |
| Roll | 109132 | ROLL | 50% | | — | ✓ |
| Chi Torpedo | 115008 | CHI_TORPEDO | 60% | | — | ✓ |
| Tiger's Lust | 116841 | TIGERS_LUST | 100% | | — | ✓ |
| Transcendence | 101643 | TRANSCENDENCE | 100% | | — | ✓ |
| Transcendence: Transfer | 119996 | TRANS_TRANSFER | 100% | | — | ✓ |
| Zen Flight | 125883 | ZEN_FLIGHT | 100% | | — | ✓ |
| Paralysis | 115078 | PARALYSIS | 100% | | — | |
| Leg Sweep | 119381 | LEG_SWEEP | 100% | | — | |
| Ring of Peace | 116844 | RING_OF_PEACE | 100% | | — | |
| Disable | 116095 | DISABLE | 50% | | — | |
| Detox | 218164 | DETOX | 100% | | — | |
| Expel Harm | 322101 | EXPEL_HARM | 30% | | — | |
| Provoke | 115546 | TAUNT | 100% | | — | |
| Spear Hand Strike | 116705 | INTERRUPT | 100% | | — | |
| Keg Smash | 121253 | KEG_SMASH | 40% | | — | |
| Breath of Fire | 115181 | BREATH_OF_FIRE | 60% | | — | |
| Purifying Brew | 119582 | PURIFYING_BREW | 50% | | — | |
| Fortifying Brew | 115203 | FORTIFYING_BREW | 100% | ✓ | 3s | |
| Black Ox Brew | 115399 | BLACK_OX_BREW | 100% | | — | |
| Exploding Keg | 325153 | EXPLODING_KEG | 100% | | — | |
| Renewing Mist | 115151 | RENEWING_MIST | 40% | | — | |
| Soothing Mist | 115175 | SOOTHING_MIST | 40% | | — | |
| Mana Tea | 197908 | MANA_TEA | 60% | | — | |
| Life Cocoon | 116849 | LIFE_COCOON | 100% | ✓ | 3s | |
| Summon Jade Serpent Statue | 115313 | STATUE_SUMMON | 100% | | — | ✓ |
| Summon Black Ox Statue | 115315 | STATUE_SUMMON | 100% | | — | ✓ |
| Revival | 115310 | REVIVAL_CAST | 100% | ✓ | 3s | |
| Thunder Focus Tea | 116680 | MAJOR_COOLDOWN | 100% | ✓ | 3s | |
| Celestial Brew | 322507 | MAJOR_COOLDOWN | 100% | ✓ | 3s | |

**Interrupt miss:** Spear Hand Strike (116705) failing or being interrupted plays an INTERRUPT_FAIL line (2 files).

⁴ Zenith Stomp (1272696) may be an automatic proc from Zenith rather than a discrete player cast; if it never fires in-game, the Zenith line (1249625) already covers the cooldown. See `sounds_list.md`.

See `sounds_list.md` for the full per-file reference, spell-ID verification status, and all ambiguous-filename judgment calls.

---

## Sound Files

All files live flat under `sounds/`. `.ogg` for voice lines; `.mp3` for AFK music beds. All play through the **Dialog** channel.

### Ambient
`login.ogg` · `select_1..13.ogg` · `aggro_1,2,3,5,6,7,8.ogg` · `leavecombat_1..5.ogg` · `death_1..5.ogg` · `revived_1..4.ogg` · `mount_1..12.ogg` · `afkstart.ogg` · `afkmusic_1..5.mp3` · `afkend.ogg`

### Windwalker
`tigerpalm.ogg` · `blackoutkick.ogg` · `risingsunkickcrit.ogg` · `spinningcranekick.ogg` · `fistoffury_1,2.ogg` · `cracklingjadelightning.ogg` · `chiburst.ogg` · `rushingwindkick.ogg` · `touchofdeath_1..3.ogg` · `touchofkarma.ogg` · `sowl-wdp.ogg` · `zenith.ogg` · `zenithstomp.ogg` · `celestialconduit.ogg` · `flyingserpentkick-slicingwinds.ogg` · `chiji-yulon-blackox-whitetiger_1,2.ogg`

### Movement / Utility
`roll.ogg` · `lighterthanair.ogg` · `chitorpedo.ogg` · `tigerslust_1,2.ogg` · `transcendence.ogg` · `transcendenceTeleport.ogg` · `zenflight.ogg` · `paralysis.ogg` · `legsweep.ogg` · `ringofpeace.ogg` · `disable_2.ogg` · `detox.ogg` · `expelharm.ogg` · `taunt_1..7.ogg` · `interrupt_1..4.ogg` · `interruptfail_1,2.ogg` · `disarm.ogg`

### Brewmaster
`kegsmash.ogg` · `breathoffire.ogg` · `purifyingbrew_1..3.ogg` · `fortifyingbrew_1..3.ogg` · `blackoxbrew_1.ogg` · `explodingkeg_1,2.ogg`

### Mistweaver
`renewingmist_1,2.ogg` · `soothingmist.ogg` · `manatea_1,2.ogg` · `chicacoon.ogg` · `mw-bmstatue.ogg` · `revival.ogg` · `revive_1..5.ogg`

### Shared
`thunderfocustea-celestialinfusion-celestialbrew.ogg`

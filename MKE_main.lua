-- MonkExperience (MKE) — Monk class voice pack for WoW Midnight (12.x)
-- Only load for Monks (classId 10)
local _, _, classId = UnitClass("player")
if classId ~= 10 then return end

local MKE_settings = MKE_settings or {}
local MKE_soundEnabled = MKE_settings.soundEnabled ~= false
local MKE_debugEnabled = MKE_settings.debugEnabled == true
local MKE_GLOBAL_CD = MKE_settings.globalCD or 0

local function MKE_Debug(msg)
    if MKE_debugEnabled then
        print("|cff00C0A3[MKE] DEBUG|r " .. msg)
    end
end

local MKE_lastSoundTime = 0
local MKE_playLock = 0
local MKE_currentHandle  = nil
local MKE_currentIsForce = false
local MKE_currentIsLowPriority = false

-- Separate from MKE_playLock: a short grace window after ANY force/normal
-- sound starts, during which lowPriority sounds are blocked from playing at
-- all. This is what stops a filler from overlapping a normal/force sound that
-- has no explicit protect, without making normal sounds unable to cut each
-- other (which giving them all a real protect would do).
local MKE_normalGraceUntil = 0
local MKE_LOWPRIORITY_GRACE = 1.5

local function CanPlay()
    local now = GetTime()
    if now < MKE_playLock then return false end
    if (now - MKE_lastSoundTime) < MKE_GLOBAL_CD then return false end
    MKE_lastSoundTime = now
    return true
end

local MKE_lastPlayed = {}

local ADDON_PATH = "Interface\\AddOns\\MonkExperience\\sounds\\"

-- Roll a weighted-random file from a category pool.
-- Returns chosen file and its per-file protect (s[3]).
local function RollSound(sounds, category)
    -- Micro-optimization: single-file categories skip the weighting loop entirely.
    if #sounds == 1 then
        return sounds[1][1], sounds[1][3]
    end

    local lastFile = MKE_lastPlayed[category]
    local totalWeight = 0
    for _, s in ipairs(sounds) do
        local w = s[2] or 1
        if s[1] == lastFile then w = w * 0.1 end
        totalWeight = totalWeight + w
    end

    local roll = math.random() * totalWeight
    local chosen, chosenProtect
    local cumulative = 0
    for _, s in ipairs(sounds) do
        local w = s[2] or 1
        if s[1] == lastFile then w = w * 0.1 end
        cumulative = cumulative + w
        if roll <= cumulative then
            chosen = s[1]
            chosenProtect = s[3]
            break
        end
    end
    if not chosen then
        chosen = sounds[#sounds][1]
        chosenProtect = sounds[#sounds][3]
    end
    return chosen, chosenProtect
end

local function PlayRandom(category, force, protectDuration, lowPriority)
    if not MKE_soundEnabled then return end
    local now = GetTime()

    if force then
        -- Force sounds update the global-CD stamp anyway
        MKE_lastSoundTime = now
    else
        if now < MKE_playLock then
            MKE_Debug("[" .. category .. "] blocked: protect window active")
            return
        end
        if not CanPlay() then
            MKE_Debug("[" .. category .. "] blocked: global CD not elapsed")
            return
        end
    end

    -- lowPriority-only grace check: blocks a filler from starting while a
    -- normal/force sound is still within its short grace window, without
    -- giving that normal/force sound a real protect (which would also stop
    -- it from being cut by another normal sound).
    if lowPriority and now < MKE_normalGraceUntil then
        MKE_Debug("[" .. category .. "] blocked: normal/force grace window active")
        return
    end

    local sounds = MKE_Sounds[category]
    if not sounds or #sounds == 0 then return end

    local chosen, chosenProtect = RollSound(sounds, category)
    MKE_lastPlayed[category] = chosen

    -- Force: stop whatever is playing and clear the protect lock.
    -- Low-priority: only stops another currently-playing low-priority sound
    -- (never a force/normal one) — so two fillers still cut each other, but
    -- neither can interrupt Leg Sweep/Interrupt/etc. StopSound is called with
    -- an explicit 0ms fadeout so the cut is immediate, not a crossfade — a
    -- default/omitted fadeout was the actual cause of audible overlap between
    -- back-to-back fillers.
    -- Normal (non-force, non-low-priority): cuts any other non-force sound.
    if force then
        if MKE_currentHandle then pcall(StopSound, MKE_currentHandle, 0) end
        MKE_playLock = 0
    elseif lowPriority then
        if MKE_currentIsLowPriority and MKE_currentHandle then
            pcall(StopSound, MKE_currentHandle, 0)
        end
    elseif not MKE_currentIsForce and MKE_currentHandle then
        pcall(StopSound, MKE_currentHandle, 0)
    end

    MKE_Debug("[" .. category .. "] playing: " .. chosen)
    local ok, success, handle = pcall(PlaySoundFile, ADDON_PATH .. chosen, "Dialog")
    MKE_currentHandle  = (ok and success) and handle or nil
    MKE_currentIsForce = force or false
    MKE_currentIsLowPriority = (not force) and lowPriority or false
    if not lowPriority then
        MKE_normalGraceUntil = now + MKE_LOWPRIORITY_GRACE
    end
    local effectiveProtect = chosenProtect or protectDuration
    if effectiveProtect then MKE_playLock = now + effectiveProtect end
end

-- ===========================================================================
-- Sound pools (files live flat under sounds/; reference by filename)
-- ===========================================================================
MKE_Sounds = {
    -- Ambient
    LOGIN       = { {"login_1.ogg", 1, 11.2} }, -- protect = own runtime + buffer
    SELECT      = {
        {"select_1.ogg", 1}, {"select_2.ogg", 1}, {"select_3.ogg", 1},
         {"select_5.ogg", 1}, {"select_6.ogg", 1},
        {"select_7.ogg", 1}, {"select_8.ogg", 1}, {"select_9.ogg", 1},
        {"select_10.ogg", 1}, {"select_11.ogg", 1}, {"select_12.ogg", 1},
        {"select_13.ogg", 1},
    },
    AGGRO       = { {"aggro_2.ogg", 1} },
    LEAVECOMBAT = { {"leavecombat_2.ogg", 1} },
    DEATH       = {
        {"death_1.ogg", 1}, {"death_2.ogg", 1},
    },
    REVIVE      = { -- ambient: player coming back to life (canlanma → revived)
        -- protect (3rd value) = each file's own runtime + small buffer, so it always plays out in full
        {"revived_1.ogg", 1, 1.6}, {"revived_2.ogg", 1, 4.6},
        {"revived_3.ogg", 1, 3.1},
    },
    MOUNT       = {
        {"mount_1.ogg", 1}, {"mount_3.ogg", 1}, {"mount_4.ogg", 1},
        {"mount_5.ogg", 1}, {"mount_6.ogg", 1}, {"mount_7.ogg", 1},
        {"mount_8.ogg", 1}, {"mount_10.ogg", 1},
        {"mount_11.ogg", 1}, {"mount_12.ogg", 1},
    },
    AFK_START   = { {"afkstart_1.ogg", 1} }, -- stinger, always plays first
    AFK_MUSIC   = { -- random music bed, plays right after the stinger, loops while still AFK
        -- 3rd value = each file's own runtime + small buffer, used to schedule the next loop iteration
        {"afkmusic_1.mp3", 1, 52.0}, {"afkmusic_2.mp3", 1, 87.7}, {"afkmusic_3.mp3", 1, 54.6},
        {"afkmusic_4.mp3", 1, 49.9}, {"afkmusic_5.mp3", 1, 82.0},
    },
    AFK_END     = { {"afkend_1.ogg", 1, 7} },

    -- Spell categories
    TIGER_PALM            = { {"tigerpalm_1.ogg", 1} },
    BLACKOUT_KICK         = { {"blackoutkick.ogg", 1} },
    RISING_SUN_KICK       = { {"risingsunkick_2.ogg", 1} },
    RUSHING_WIND_KICK     = { {"risingsunkick_1.ogg", 1} },
    SPINNING_CRANE_KICK   = { {"spinningcranekick_1.ogg", 1} },
    FISTS_OF_FURY         = { {"fistsoffury_1.ogg", 1} },
    CRACKLING_JADE        = { {"cracklingjadelightning_1.ogg", 1} },
    CHI_BURST             = { {"chiburst_1.ogg", 1} },
    TOUCH_OF_DEATH        = { -- protect (3rd value) = each file's own runtime + small buffer
        {"touchofdeath_2.ogg", 1, 1.4}
    },
    TOUCH_OF_KARMA        = { {"touchofkarma_1.ogg", 1} },
    STRIKES               = { {"sowl-wdp_1.ogg", 1} }, -- Strike of the Windlord + Whirling Dragon Punch
    ZENITH                = { {"zenith_1.ogg", 1, 2.7} }, -- protect = own runtime + buffer
    ZENITH_STOMP          = { {"zenitstomp_1.ogg", 1}, {"zenithstomp_2.ogg", 1} },
    CELESTIAL_CONDUIT     = { {"celestialconduit_1.ogg", 1, 4.9} }, -- protect = own runtime + buffer
    CELESTIAL_SUMMON      = { {"chiji-yulon-blackox-whitetiger_1.ogg", 1, 2.1} }, -- protect = own runtime + buffer
    FLYING_SERPENT_KICK   = { {"flyingserpentkick-slicingwinds_1.ogg", 1}, {"flyingserpentkick-slicingwinds_2.ogg", 1} }, -- shared: Flying Serpent Kick + Slicing Winds
    GRAPPLE_WEAPON        = { {"grappleweapon_1.ogg", 1} },

    -- Movement / utility (out of combat)
    ROLL          = { {"roll_1.ogg", 1} },
    TIGERS_LUST   = { {"tigerslust_1.ogg", 1} },
    TRANSCENDENCE = { {"transcendence_1.ogg", 1} },
    TRANS_TRANSFER = { {"transcendenceTeleport_1.ogg", 1} },
    ZEN_FLIGHT    = { {"zenflight_1.ogg", 1} },

    -- Control / utility
    PARALYSIS   = { {"paralysis_1.ogg", 1} },
    LEG_SWEEP   = { {"legsweep_1.ogg", 1}, {"legsweep_2.ogg", 1} },
    RING_OF_PEACE = { {"ringofpeace_1.ogg", 1} },
    DISABLE     = { {"disable_1.ogg", 1} },
    DETOX       = { {"detox_1.ogg", 1} },
    EXPEL_HARM  = { {"expelharm_1.ogg", 1} },
    TAUNT       = {
        {"taunt_1.ogg", 1}, {"taunt_2.ogg", 1}, {"taunt_3.ogg", 1},
        {"taunt_4.ogg", 1}, {"taunt_5.ogg", 1}, {"taunt_6.ogg", 1},
        {"taunt_7.ogg", 1},
    },
    INTERRUPT   = { -- Spear Hand Strike
         {"interrupt_2.ogg", 1}, {"interrupt_4.ogg", 1}
    },
    INTERRUPT_FAIL = { {"interruptfail_1.ogg", 1}, {"interruptfail_2.ogg", 1} },

    -- Brewmaster
    KEG_SMASH      = { {"kegsmash_1.ogg", 1} },
    BREATH_OF_FIRE = { {"breathoffire_1.ogg", 1} },
    PURIFYING_BREW = { {"purifyingbrew_1.ogg", 1}, {"purifyingbrew_2.ogg", 1}, {"purifyingbrew_3.ogg", 1} },
    FORTIFYING_BREW = { {"fortifyingbrew_1.ogg", 1, 2.5} }, -- protect = own runtime + buffer
    BLACK_OX_BREW  = { {"blackoxbrew_1.ogg", 1} },
    EXPLODING_KEG  = { {"explodingkeg_1.ogg", 1, 4.4}, {"explodingkeg_2.ogg", 1, 2.7} }, -- protect = own runtime + buffer

    -- Mistweaver
    RENEWING_MIST = { {"renewingmist_1.ogg", 1}, {"renewingmist_2.ogg", 1} },
    SOOTHING_MIST = { {"soothingmist_1.ogg", 1}, {"soothingmist_2.ogg", 1} },
    MANA_TEA      = { {"manatea_1.ogg", 1} },
    LIFE_COCOON   = { {"chicacoon_1.ogg", 1, 2.6} }, -- protect = own runtime + buffer
    STATUE_SUMMON = { {"mw-bmstatue_1.ogg", 1} },
    REVIVAL_CAST     = { {"revival-restoral_1.ogg", 1} }, -- Revival + Restoral: the AoE raid-cooldown resurrection
    RESUSCITATE_CAST = { -- Resuscitate: single-target out-of-combat resurrection
        {"resuscitate_1.ogg", 1}, {"resuscitate_2.ogg", 1}, {"resuscitate_3.ogg", 1},
        {"resuscitate_4.ogg", 1}, {"resuscitate_5.ogg", 1},
    },
    REAWAKEN = { {"reawaken_1.ogg", 1} }, -- mass out-of-combat resurrection

    -- Shared major-cooldown bundle: Thunder Focus Tea + Celestial Brew
    MAJOR_COOLDOWN = { {"thunderfocustea-celestialinfusion-celestialbrew_1.ogg", 1, 2.6} }, -- protect = own runtime + buffer
}

-- ===========================================================================
-- Spell → sound mapping
-- fields: cat, prob, force, anyCombat, protect, onCastStart, requiresSpell
-- ===========================================================================
local SpellToSound = {
    -- Core rotational
    [100780] = { cat = "TIGER_PALM",          prob = 0.25, anyCombat = true, lowPriority = true },
    [100784] = { cat = "BLACKOUT_KICK",       prob = 0.25, anyCombat = true, lowPriority = true },
    [205523] = { cat = "BLACKOUT_KICK",       prob = 0.25, anyCombat = true, lowPriority = true }, -- Blackout Kick (Brewmaster), shares Blackout Kick's sound
    [107428] = { cat = "RISING_SUN_KICK",     prob = 0.25 , anyCombat = true , lowPriority = true },
    [101546] = { cat = "SPINNING_CRANE_KICK", prob = 0.25, anyCombat = true, lowPriority = true },
    [113656] = { cat = "FISTS_OF_FURY",       prob = 1.0, anyCombat = true ,lowPriority = true},
    [117952] = { cat = "CRACKLING_JADE",      prob = 1.0, anyCombat = true, lowPriority = true },
    [123986] = { cat = "CHI_BURST",           prob = 1.0, anyCombat = true , onCastStart = true  },
    [467307] = { cat = "RUSHING_WIND_KICK",   prob = 1.0, probBySpec = { [270] = 0.3 }, anyCombat = true, lowPriority = true }, -- full chance on Windwalker, lower on Mistweaver

    -- Windwalker cooldowns / signatures
    [322109] = { cat = "TOUCH_OF_DEATH",   prob = 1.0, force = true, anyCombat = true }, -- protect is now dynamic (per-file)
    [122470] = { cat = "TOUCH_OF_KARMA",   prob = 1.0, anyCombat = true },
    [392983] = { cat = "STRIKES",          prob = 1.0, anyCombat = true }, -- Strike of the Windlord
    [152175] = { cat = "STRIKES",          prob = 1.0, anyCombat = true }, -- Whirling Dragon Punch
    [1249625] = { cat = "ZENITH",          prob = 1.0, force = true, anyCombat = true }, -- Zenith (Shado-Pan); protect is now dynamic (per-file)
    [1272696] = { cat = "ZENITH_STOMP",    prob = 1.0, anyCombat = true }, -- Zenith Stomp (may be an auto-proc; see notes)
    [443028] = { cat = "CELESTIAL_CONDUIT", prob = 1.0, force = true, anyCombat = true }, -- protect is now dynamic (per-file)
    [101545] = { cat = "FLYING_SERPENT_KICK", prob = 1.0, anyCombat = true }, -- Flying Serpent Kick
    [1217413] = { cat = "FLYING_SERPENT_KICK", prob = 1.0, anyCombat = true }, -- Slicing Winds
    [233759] = { cat = "GRAPPLE_WEAPON", prob = 1.0, anyCombat = true }, -- Grapple Weapon (PvP talent, disarm-like)

    -- Celestial summons (all specs) — force major cooldowns; protect is now dynamic (per-file)
    [123904] = { cat = "CELESTIAL_SUMMON", prob = 1.0, force = true, anyCombat = true }, -- Invoke Xuen
    [322118] = { cat = "CELESTIAL_SUMMON", prob = 1.0, force = true, anyCombat = true }, -- Invoke Yu'lon
    [325197] = { cat = "CELESTIAL_SUMMON", prob = 1.0, force = true, anyCombat = true }, -- Invoke Chi-Ji
    [132578] = { cat = "CELESTIAL_SUMMON", prob = 1.0, force = true, anyCombat = true }, -- Invoke Niuzao

    -- Movement / utility
    [109132] = { cat = "ROLL",           prob = 1.0, anyCombat = true }, -- Roll
    [115008] = { cat = "ROLL",           prob = 1.0, anyCombat = true }, -- Chi Torpedo, shares Roll's sound
    [116841] = { cat = "TIGERS_LUST",    prob = 1.0, anyCombat = true }, -- Tiger's Lust
    [101643] = { cat = "TRANSCENDENCE",  prob = 1.0, anyCombat = true }, -- Transcendence
    [119996] = { cat = "TRANS_TRANSFER", prob = 1.0, anyCombat = true }, -- Transcendence: Transfer
    [125883] = { cat = "ZEN_FLIGHT",     prob = 1.0, anyCombat = true }, -- Zen Flight

    -- Control / utility
    [115078] = { cat = "PARALYSIS",     prob = 1.0, anyCombat = true },
    [119381] = { cat = "LEG_SWEEP",     prob = 1.0, anyCombat = true },
    [116844] = { cat = "RING_OF_PEACE", prob = 1.0, anyCombat = true },
    [198898] = { cat = "RING_OF_PEACE", prob = 1.0, anyCombat = true, onCastStart = true }, -- Song of Chi-Ji, shares Ring of Peace's sound
    [202370] = { cat = "RING_OF_PEACE", prob = 1.0, anyCombat = true }, -- Mighty Ox Kick, Brewmaster PvP talent, shares Ring of Peace's sound
    [116095] = { cat = "DISABLE",       prob = 1.0, anyCombat = true, lowPriority = true },
    [218164] = { cat = "DETOX",         prob = 1.0, anyCombat = true },
    [115450] = { cat = "DETOX",         prob = 1.0, anyCombat = true }, -- Mistweaver Detox, shares Detox's sound
    [322101] = { cat = "EXPEL_HARM",    prob = 1.0, anyCombat = true },
    [115546] = { cat = "TAUNT",         prob = 1.0, anyCombat = true }, -- Provoke
    [207025] = { cat = "TAUNT",         prob = 1.0, anyCombat = true }, -- Admonishment, Brewmaster PvP talent, shares Taunt's sound
    [116705] = { cat = "INTERRUPT",     prob = 1.0, anyCombat = true }, -- Spear Hand Strike (success)

    -- Brewmaster
    [121253] = { cat = "KEG_SMASH",       prob = 0.25, anyCombat = true, lowPriority = true },
    [115181] = { cat = "BREATH_OF_FIRE",  prob = 0.25, anyCombat = true, lowPriority = true },
    [119582] = { cat = "PURIFYING_BREW",  prob = 1.0, anyCombat = true },
    [115203] = { cat = "FORTIFYING_BREW", prob = 1.0, force = true, anyCombat = true }, -- protect is now dynamic (per-file)
    [115399] = { cat = "BLACK_OX_BREW",   prob = 1.0, anyCombat = true },
    [325153] = { cat = "EXPLODING_KEG",   prob = 1.0, force = true, anyCombat = true }, -- protect is dynamic (per-file)
    [115315] = { cat = "STATUE_SUMMON",   prob = 1.0, anyCombat = true }, -- Summon Black Ox Statue

    -- Mistweaver
    [115151] = { cat = "RENEWING_MIST", prob = 0.25, anyCombat = true, lowPriority = true },
    [115175] = { cat = "SOOTHING_MIST", prob = 1.0, anyCombat = true },
    [197908] = { cat = "MANA_TEA",      prob = 1.0, anyCombat = true },
    [115294] = { cat = "MANA_TEA",      prob = 1.0, anyCombat = true }, -- Mana Tea; instant cast, fires on succeeded (no UNIT_SPELLCAST_START for instants)
    [115869] = { cat = "MANA_TEA",      prob = 1.0, anyCombat = true }, -- Mana Tea (alt ID); instant cast, fires on succeeded
    [116849] = { cat = "LIFE_COCOON",   prob = 1.0, force = true, anyCombat = true }, -- Life Cocoon; protect is now dynamic (per-file)
    [115313] = { cat = "STATUE_SUMMON", prob = 1.0, anyCombat = true }, -- Summon Jade Serpent Statue
    [115310] = { cat = "REVIVAL_CAST",     prob = 1.0, anyCombat = true}, -- Revival, AoE (plays when cast begins)
    [388615] = { cat = "REVIVAL_CAST",     prob = 1.0, anyCombat = true}, -- Restoral, shares Revival's file/bucket
    [115178] = { cat = "RESUSCITATE_CAST", prob = 1.0, anyCombat = true, onCastStart = true }, -- Resuscitate, single-target (plays when cast begins)
    [212051] = { cat = "REAWAKEN",         prob = 1.0, anyCombat = true, onCastStart = true }, -- Reawaken, mass out-of-combat rez

    -- Shared major-cooldown bundle; protect is now dynamic (per-file)
    [116680] = { cat = "MAJOR_COOLDOWN", prob = 1.0, force = true, anyCombat = true }, -- Thunder Focus Tea
    [322507] = { cat = "MAJOR_COOLDOWN", prob = 1.0, force = true, anyCombat = true }, -- Celestial Brew
    [1241059] = { cat = "MAJOR_COOLDOWN", prob = 1.0, force = true, anyCombat = true }, -- Celestial Infusion
}

-- Spell IDs whose FAILED/INTERRUPTED cast should trigger an interrupt-miss line.
local InterruptFailSpells = {
    [116705] = true, -- Spear Hand Strike
}

local INTERRUPT_FAIL_CD = 5 -- own cooldown, independent of the protect-lock system
local interruptFailLastPlayed = 0

local AGGRO_CD = 20 -- own cooldown, independent of the protect-lock system
local aggroLastPlayed = 0
local LEAVECOMBAT_CD = 20 -- own cooldown, independent of the protect-lock system
local leaveCombatLastPlayed = 0

-- Monk spec IDs: 268 Brewmaster, 270 Mistweaver, 269 Windwalker
local function CurrentSpecID()
    local specIndex = GetSpecialization()
    if not specIndex then return nil end
    local specID = GetSpecializationInfo(specIndex)
    return specID
end

local function HandleResolvedSpell(spellID, fromCastStart)
    local cfg = SpellToSound[spellID]
    if not cfg then
        MKE_Debug("unmapped spellID=" .. tostring(spellID) .. (fromCastStart and " (castStart)" or " (succeeded)"))
        return
    end
    if fromCastStart and not cfg.onCastStart then
        MKE_Debug("spell=" .. tostring(spellID) .. " skipped: castStart event, cfg wants succeeded")
        return
    end
    if not fromCastStart and cfg.onCastStart then
        MKE_Debug("spell=" .. tostring(spellID) .. " skipped: succeeded event, cfg wants castStart (likely an instant-cast spell that never fires UNIT_SPELLCAST_START)")
        return
    end
    if cfg.requiresSpell and not IsPlayerSpell(cfg.requiresSpell) then return end
    if not cfg.anyCombat and not InCombatLockdown() then
        MKE_Debug("spell=" .. tostring(spellID) .. " skipped: out of combat")
        return
    end
    local prob = cfg.prob
    if cfg.probBySpec then
        local specID = CurrentSpecID()
        if specID and cfg.probBySpec[specID] then
            prob = cfg.probBySpec[specID]
        end
    end
    if math.random() > prob then
        MKE_Debug("spell=" .. tostring(spellID) .. " → " .. cfg.cat .. " (prob gate failed)")
        return
    end
    MKE_Debug("spell=" .. tostring(spellID) .. " → " .. cfg.cat)
    PlayRandom(cfg.cat, cfg.force, cfg.protect, cfg.lowPriority)
end

-- ===========================================================================
-- Ambient state tracking
-- ===========================================================================
local prevDead       = false
local prevCombat     = false
local prevMounted    = false
local prevAFK        = false
local prevSelfTarget = false
local afkSoundHandle = nil
local afkMusicTimer  = nil
local pollTimer      = 0
local POLL           = 0.2

local AFK_STINGER_DURATION = 3.8 -- afkstart_1.ogg runtime (~3.76s) + small buffer

local function IsStillAFK()
    local ok, isAFK = pcall(function()
        return UnitIsAFK("player") and true or false
    end)
    return ok and isAFK
end

local function PlayAFKMusic()
    if not MKE_soundEnabled then return end
    local pool = MKE_Sounds.AFK_MUSIC
    local chosen, chosenDuration = RollSound(pool, "AFK_MUSIC")
    MKE_lastPlayed.AFK_MUSIC = chosen
    local ok, success, handle = pcall(PlaySoundFile, ADDON_PATH .. chosen, "Dialog")
    afkSoundHandle = (ok and success) and handle or nil
    MKE_Debug("AFK music playing: " .. chosen)

    -- Loop: when this track's own runtime elapses, play another random one,
    -- as long as we're still AFK. Re-checked each time so the loop stops
    -- naturally on return from AFK instead of running forever.
    afkMusicTimer = C_Timer.NewTimer(chosenDuration or 60, function()
        afkMusicTimer = nil
        if IsStillAFK() then
            PlayAFKMusic()
        end
    end)
end

local function PlayAFKStart()
    if not MKE_soundEnabled then return end
    local pool = MKE_Sounds.AFK_START
    local chosen = RollSound(pool, "AFK_START")
    MKE_lastPlayed.AFK_START = chosen
    local ok, success, handle = pcall(PlaySoundFile, ADDON_PATH .. chosen, "Dialog")
    afkSoundHandle = (ok and success) and handle or nil
    MKE_Debug("AFK start playing: " .. chosen)

    afkMusicTimer = C_Timer.NewTimer(AFK_STINGER_DURATION, function()
        afkMusicTimer = nil
        if IsStillAFK() then
            PlayAFKMusic()
        end
    end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
frame:RegisterEvent("UNIT_SPELLCAST_START")
frame:RegisterEvent("UNIT_SPELLCAST_FAILED")
frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")

local loginLastPlayed = nil
frame:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        prevMounted = IsMounted()
        local now = GetTime()
        if not loginLastPlayed or (now - loginLastPlayed) >= 3600 then
            loginLastPlayed = now
            MKE_Debug("state: LOGIN")
            PlayRandom("LOGIN", true)
        end
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit, _, spellID = ...
        if unit == "player" then HandleResolvedSpell(spellID, false) end
    elseif event == "UNIT_SPELLCAST_START" then
        local unit, _, spellID = ...
        if unit == "player" then HandleResolvedSpell(spellID, true) end
    elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" then
        local unit, _, spellID = ...
        if unit == "player" and InterruptFailSpells[spellID] then
            local now = GetTime()
            if now - interruptFailLastPlayed >= INTERRUPT_FAIL_CD then
                interruptFailLastPlayed = now
                MKE_Debug("interrupt miss: spellID=" .. tostring(spellID))
                PlayRandom("INTERRUPT_FAIL", nil, nil, true)
            else
                MKE_Debug("interrupt miss: spellID=" .. tostring(spellID) .. " blocked (own 5s CD)")
            end
        end
    end
end)

frame:SetScript("OnUpdate", function(_, elapsed)
    pollTimer = pollTimer + elapsed
    if pollTimer < POLL then return end
    pollTimer = 0

    -- Death / Revive (ambient)
    local isDead = UnitIsDeadOrGhost("player")
    if isDead and not prevDead then
        MKE_Debug("state: DEATH")
        PlayRandom("DEATH", true)
    elseif not isDead and prevDead then
        MKE_Debug("state: REVIVE")
        PlayRandom("REVIVE", true)
    end
    prevDead = isDead

    -- Combat enter / leave
    local inCombat = InCombatLockdown()
    if inCombat and not prevCombat then
        MKE_Debug("state: ENTER COMBAT")
        local nowAggro = GetTime()
        if nowAggro - aggroLastPlayed >= AGGRO_CD then
            aggroLastPlayed = nowAggro
            PlayRandom("AGGRO", false, nil, true)
        else
            MKE_Debug("AGGRO blocked (own 20s CD)")
        end
    elseif not inCombat and prevCombat then
        MKE_Debug("state: LEAVE COMBAT")
        if not isDead then
            local nowLeave = GetTime()
            if nowLeave - leaveCombatLastPlayed >= LEAVECOMBAT_CD then
                leaveCombatLastPlayed = nowLeave
                PlayRandom("LEAVECOMBAT", false, nil, true)
            else
                MKE_Debug("LEAVECOMBAT blocked (own 20s CD)")
            end
        end
    end
    prevCombat = inCombat

    -- Mount
    local mounted = IsMounted()
    if mounted and not prevMounted then
        MKE_Debug("state: MOUNT")
        PlayRandom("MOUNT")
    end
    prevMounted = mounted

    -- AFK
    local okAFK, afkEvent = pcall(function()
        local isAFK = UnitIsAFK("player")
        if isAFK and not prevAFK then
            prevAFK = true
            return "AFKSTART"
        elseif not isAFK and prevAFK then
            prevAFK = false
            return "AFKEND"
        end
    end)
    if okAFK and afkEvent == "AFKSTART" then
        MKE_Debug("state: AFK START")
        PlayAFKStart()
    elseif okAFK and afkEvent == "AFKEND" then
        MKE_Debug("state: AFK END")
        if afkMusicTimer then
            afkMusicTimer:Cancel()
            afkMusicTimer = nil
        end
        if afkSoundHandle then
            pcall(StopSound, afkSoundHandle, 0)
            afkSoundHandle = nil
        end
        PlayRandom("AFK_END", true)
    end

    -- Self-target
    local selfTarget = UnitExists("target") and UnitIsUnit("target", "player")
    if selfTarget and not prevSelfTarget then
        MKE_Debug("state: SELF-TARGET")
        PlayRandom("SELECT")
    end
    prevSelfTarget = selfTarget
end)

-- ===========================================================================
-- Slash command: /vgm on | off | debug | cd <seconds>
-- ===========================================================================
SLASH_MKE1 = "/vgm"
SlashCmdList["MKE"] = function(msg)
    local cmd, arg = msg:match("^(%S+)%s*(.*)$")
    if not cmd then cmd = "" end
    cmd = cmd:lower()

    if cmd == "on" then
        MKE_soundEnabled = true
        MKE_settings.soundEnabled = true
        print("|cff00C0A3Monk Experience:|r Sounds |cff00FF00enabled|r.")
    elseif cmd == "off" then
        MKE_soundEnabled = false
        MKE_settings.soundEnabled = false
        print("|cff00C0A3Monk Experience:|r Sounds |cffFF0000disabled|r.")
    elseif cmd == "debug" then
        MKE_debugEnabled = not MKE_debugEnabled
        MKE_settings.debugEnabled = MKE_debugEnabled
        print("|cff00C0A3Monk Experience:|r Debug " .. (MKE_debugEnabled and "|cff00FF00on|r" or "|cffFF0000off|r") .. ".")
    elseif cmd == "cd" then
        local val = tonumber(arg)
        if val and val >= 0 then
            MKE_GLOBAL_CD = val
            MKE_settings.globalCD = val
            print("|cff00C0A3Monk Experience:|r Global cooldown set to |cffFFFF00" .. val .. "|r seconds.")
        else
            print("|cff00C0A3Monk Experience:|r Usage: /vgm cd <seconds>")
        end
    else
        print("|cff00C0A3Monk Experience:|r Commands:")
        print("  /vgm on    — enable sounds")
        print("  /vgm off   — disable sounds")
        print("  /vgm debug — toggle debug output")
        print("  /vgm cd <seconds> — set global cooldown between sounds")
    end
end

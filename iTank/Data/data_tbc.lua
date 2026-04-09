-- TBC overrides (2.x, e.g., 20505)
local _, ns = ...
ITank = ITank or {}
ITank.Data = ITank.Data or {}

do
    local v = ITank.Data.GameVersion
    local cur = v and v.Current or (select(4, GetBuildInfo()) or 0)
    if cur >= 20000 and cur < 30000 then
        ITank.Data.IsTBC = true

        -- Boss level helper: 70 vs 73
        function ITank.Data:GetBossLevelForDefense(playerLevel)
            if not playerLevel then playerLevel = UnitLevel("player") end
            if not playerLevel then return 73 end
            if playerLevel == 70 then return 73 end
            return playerLevel + 3
        end

        -- Rating conversions (per 1% at level 70)
        ITank.Data.Ratings = {
            MeleeHit = 15.77,
            RangedHit = 15.77,
            SpellHit = 12.62,
            Haste = 15.77,
            Expertise = 3.9423,      -- rating per 1 expertise skill
            Dodge = 18.9,            -- rating per 1% dodge
            Parry = 23.6538,         -- rating per 1% parry
            Block = 7.9,             -- rating per 1% block
            DefensePerSkill = 2.3654, -- defense rating per 1 defense skill
            ResilCrit = 39.4231,     -- rating per -1% crit taken
        }

        -- Hit caps overrides (boss level 73 reference)
        -- Fully override to avoid 0% defaults from base definitions
        ITank.Data.HitCaps = {
            HUNTER = 9,
            ROGUE = 9,
            WARRIOR = 9,
            PALADIN = { [1] = 9, [2] = 9, [3] = 9 },    -- Holy/Prot/Ret: default 9% (physical)
            SHAMAN  = { [1] = 16, [2] = 9, [3] = 9 },  -- Elemental 16% (spell); Enhancement 9%; Resto default 9%
            MAGE = 16,
            WARLOCK = 16,
            PRIEST = { [1] = 16, [2] = 16, [3] = 16 }, -- All caster trees use 16% cap reference
            DRUID = { [1] = 16, [2] = 9, [3] = 9 },    -- Balance 16%; Feral 9%; Resto default 9%
        }

        -- TBC-specific Hit talents configuration
        local L = ns.L or {}
        ITank.Data.HitTalentsConfig = {
            WARRIOR = { L["TALENT_PRECISION"] },                         -- +1% per rank (3 ranks)
            HUNTER  = { L["TALENT_SUREFOOTED"] },                        -- +1% per rank (3 ranks)
            ROGUE   = { L["TALENT_PRECISION"] },                         -- +1% per rank (5 ranks)
            PRIEST  = { L["TALENT_SHADOW_FOCUS"] },                      -- +1% per rank (5 ranks), Shadow only
            SHAMAN  = { [1] = { L["TALENT_ELEMENTAL_PRECISION"] },       -- +1% per rank (3 ranks) (Elemental spells)
                        [2] = { L["TALENT_NATURES_GUIDANCE"], L["TALENT_DUAL_WIELD_SPECIALIZATION"] } }, -- +3% NG, +2%/rank DWS
            MAGE    = { L["TALENT_ARCANE_FOCUS"], L["TALENT_ELEMENTAL_PRECISION"] }, -- AF +1%/rank (5), EP +1%/rank (3)
            WARLOCK = { L["TALENT_SUPPRESSION"] },                       -- Affliction spells; per-rank set below
            DRUID   = {},                                                -- no direct self hit talents in TBC
            PALADIN = { L["TALENT_PRECISION"] },                         -- Retribution/Protection: +1%/rank (3)
        }
        ITank.Data.HitTalentPerRank = {
            [L["TALENT_DUAL_WIELD_SPECIALIZATION"]] = 2, -- +2%/rank (up to 6%)
            [L["TALENT_SUPPRESSION"]] = 2,               -- +2%/rank (Affliction, up to 10% in TBC Classic may vary)
            -- others default +1%/rank
        }

        function ITank.Data:GetDraeneiAuraHitBonus()
            local bonus = 0
            for i = 1, 40 do
                local _, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
                if not spellID then break end
                if spellID == 28878 or spellID == 6562 then
                    bonus = 1
                    break
                end
            end
            return bonus
        end

        -- Fields not present in TBC should be hidden from output (handled by alt format strings)
    end
end

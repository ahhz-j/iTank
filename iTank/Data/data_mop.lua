-- MoP-specific overrides (5.x)
local _, ns = ...
ITank = ITank or {}
ITank.Data = ITank.Data or {}

do
    local build = select(4, GetBuildInfo()) or 0
    if build >= 50000 and build < 60000 then
        ITank.Data.IsMOP = true

        -- API aliases for MoP specialization (compatible with C_SpecializationInfo)
        local GetSpec = (C_SpecializationInfo and C_SpecializationInfo.GetSpecialization) or GetSpecialization
        local GetSpecInfo = (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo) or GetSpecializationInfo
        local GetInspectSpec = (C_SpecializationInfo and C_SpecializationInfo.GetInspectSpecialization) or GetInspectSpecialization
        local GetSpecInfoByID = (C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfoByID) or GetSpecializationInfoByID

        -- MoP hit caps: melee/ranged 7.5%, casters 15%
        ITank.Data.HitCaps = {
            WARRIOR = 7.5, PALADIN = 7.5, DEATHKNIGHT = 7.5, ROGUE = 7.5, MONK = 7.5,
            HUNTER = 7.5, SHAMAN = { [1] = 15, [2] = 7.5, [3] = 7.5 },
            MAGE = 15, WARLOCK = 15, PRIEST = 15,
            DRUID = { [1] = 15, [2] = 7.5, [3] = 7.5 },
        }

        -- MoP rating conversions (per 1%)
        ITank.Data.Ratings = ITank.Data.Ratings or {}
        ITank.Data.Ratings.MeleeHit = 340
        ITank.Data.Ratings.RangedHit = 340
        ITank.Data.Ratings.SpellHit = 340
        -- Expertise: treat as % conversion in MoP
        ITank.Data.Ratings.Expertise = 340

        -- Override defense panel rendering for MoP
        local baseGetDefensePanelText = ITank.Data.GetDefensePanelText
        function ITank.Data:GetDefensePanelText()
            local texts = { col1 = "", col2 = "", col3 = "" }
            local d = self:GetDefenseStats()
            if not d then return texts end

            -- Left column: Miss, Dodge, Parry, Block, Avoid(D+P)
            local avoidDP = (d.dodge or 0) + (d.parry or 0)
            texts.col1 = string.format(ns.L["DEFENSE_PANEL_TITLE_MOP"],
                d.miss or 0, d.dodge or 0, d.parry or 0, d.block or 0, avoidDP or 0)

            -- Middle column: skills (Hit, Expertise, Mastery, Armor, DR)
            local hitReqDefault = 7.5
            local hitColor = (d.finalHitPercent or 0) >= hitReqDefault and "|cff00ff00" or "|cffff0000"
            local missingHitColor
            if (d.finalHitPercent or 0) >= hitReqDefault then
                missingHitColor = "|cff00ff00" .. ns.L["STATUS_OK"]
            else
                missingHitColor = "|cffff0000" .. (d.missingHitLevel or 0) .. "|r"
            end
            local hitStr = string.format(ns.L["DEFENSE_HIT_FMT_MOP"], hitColor, d.finalHitPercent or 0, hitReqDefault, missingHitColor)

            local capSkill = 15
            local exptColor = (d.expt or 0) >= capSkill and "|cff00ff00" or "|cffff0000"
            local exptStr
            if (d.expt or 0) >= capSkill then
                exptStr = string.format(ns.L["DEFENSE_EXPT_FMT1"], exptColor, d.expt or 0, tostring(capSkill))
            else
                exptStr = string.format(ns.L["DEFENSE_EXPT_FMT2"], exptColor, d.expt or 0, tostring(capSkill), d.missExp or 0)
            end

            local masteryPct = 0
            if GetMasteryEffect then
                masteryPct = GetMasteryEffect() or 0
            elseif GetMastery then
                masteryPct = GetMastery() or 0
            end
            local masteryRating = 0
            if CR_MASTERY and GetCombatRating then
                masteryRating = GetCombatRating(CR_MASTERY) or 0
            end
            local masteryStr = string.format(ns.L["DEFENSE_MASTERY_FMT"], masteryPct, masteryRating)

            local armorStr = string.format(ns.L["DEFENSE_ARMOR_FMT"], d.effectiveArmor or 0)
            local drStr = string.format(ns.L["DEFENSE_DR_FMT"], (d.dr or 0) * 100)
            texts.col2 = string.format(ns.L["DEFENSE_SKILL_TITLE_MOP"], hitStr, exptStr, masteryStr, armorStr, drStr)

            -- Right column: AP, SP, Crit, EHP
            local baseAP, posAP, negAP = UnitAttackPower("player")
            local AP = (baseAP or 0) + (posAP or 0) + (negAP or 0)
            local sp = GetSpellBonusDamage(2) or 0
            for i = 3, 7 do
                local s = GetSpellBonusDamage(i) or 0
                if s > sp then sp = s end
            end
            local crit = GetCritChance() or 0
            local otherStr = ""
            otherStr = otherStr .. string.format(ns.L["DEFENSE_AP_FMT"], AP)
            otherStr = otherStr .. string.format(ns.L["DEFENSE_SP_FMT"], sp)
            otherStr = otherStr .. string.format(ns.L["DEFENSE_CRITRATE_FMT"], crit)
            otherStr = otherStr .. string.format(ns.L["DEFENSE_EHP_FMT"], d.hopeh or 0)
            texts.col3 = ns.L["DEFENSE_OTHER_TITLE"] .. otherStr

            return texts
        end

        -- Override iDPS panel lines for MoP
        local baseGetDPSPanelText = ITank.Data.GetDPSPanelText
        function ITank.Data:GetDPSPanelText()
            local lines = { line1 = "", line2 = "", line3 = "" }
            local L = ns.L or {}
            local function SafeFormat(fmt, ...) if not fmt then return "" end local ok,res=pcall(string.format,fmt,...) return ok and res or "" end

            -- Sets and score
            local setString, itemSets = self:GetSetInfo()
            local score = self:CalculateiDPSScore(itemSets)

            -- Primary stats
            local Str = UnitStat("player", 1) or 0
            local Agi = UnitStat("player", 2) or 0
            local Int = UnitStat("player", 4) or 0
            local Spi = UnitStat("player", 5) or 0
            local baseAP, posAP, negAP = UnitAttackPower("player")
            local AP = (baseAP or 0) + (posAP or 0) + (negAP or 0)
            local SP = GetSpellBonusDamage(2) or 0
            for i=3,7 do local s = GetSpellBonusDamage(i) or 0 if s > SP then SP = s end end

            local _, classEn = UnitClass("player")
            local isCaster = (classEn == "MAGE" or classEn == "WARLOCK" or classEn == "PRIEST")
            -- refine caster by specialization (e.g., Elemental/Balances are casters)
            local _, _, specName = self:GetMoPSpecInfo()
            if specName then
                if classEn == "SHAMAN" and (specName == "Elemental" or specName == "元素" or specName == "元素薩滿") then
                    isCaster = true
                elseif classEn == "DRUID" and (specName == "Balance" or specName == "平衡" or specName == "平衡德魯伊") then
                    isCaster = true
                end
            end

            if isCaster then
                lines.line1 = SafeFormat(L["IDPS_LINE1_MOP_CASTER"], score, Int, Spi, SP, setString)
            else
                lines.line1 = SafeFormat(L["IDPS_LINE1_MOP_MELEE"], score, Str, Agi, AP, setString)
            end

            -- Hit and Expertise
            local ratings = ITank.Data.Ratings or {}
            local ratingMeleeHit = ratings.MeleeHit or 32.79
            local ratingSpellHit = ratings.SpellHit or 26.23
            local hitReq = (isCaster and 15 or 7.5)
            local baseHitPct = isCaster and (GetCombatRatingBonus(CR_HIT_SPELL) or 0) or (GetCombatRatingBonus(CR_HIT_MELEE) or 0)
            local raceBonus = self:GetRaceHitBonus() or 0
            local hitPct = baseHitPct + raceBonus
            local hitPerPct = isCaster and ratingSpellHit or ratingMeleeHit
            local diffPct = hitPct - hitReq
            local diffLevels = math.floor(math.abs(diffPct) * hitPerPct + 0.0001)
            local hitColor = (diffPct >= 0) and "|cff00ff00" or "|cffff0000"
            local hitMissingStr
            if diffPct > 0 then
                hitMissingStr = hitColor .. tostring(diffLevels) .. "|r"
            elseif diffPct < 0 then
                hitMissingStr = hitColor .. tostring(diffLevels) .. "|r"
            else
                hitMissingStr = "|cff00ff00" .. L["STATUS_OK"] .. "|r"
            end
            -- place race bonus descriptor next to hit segment
            if iTankDB and iTankDB.ShowRaceHit then
                local _, raceEn = UnitRace("player")
                if raceEn == "Draenei" then
                    local rtxt = (GetLocale() == "zhTW") and "種族1%" or ((GetLocale() == "zhCN") and "种族1%" or "Race1%")
                    hitMissingStr = hitMissingStr .. string.format(L["HIT_BONUS_WRAPPER"], rtxt)
                end
            end

            -- Expertise: hide for Elemental Shaman only (as caster)
            local isEleSham = (classEn == "SHAMAN") and (specName == "Elemental" or specName == "元素" or specName == "元素薩滿")
            if isEleSham then
                lines.line2 = SafeFormat(L["IDPS_LINE2_MOP_CASTER"], hitColor, hitPct, hitReq, hitMissingStr)
            else
                local expt = math.floor(GetExpertise() or 0) -- treat as % in MoP
                local expCap = 15
                local expPerPercent = ratings.Expertise or 340
                local expDiffPct = expt - expCap
                local expDiffLevels = math.floor(math.abs(expDiffPct) * expPerPercent + 0.0001)
                local exptPct = expt
                local exptColor = (expDiffPct >= 0) and "|cff00ff00" or "|cffff0000"
                local exptMissingStr
                if expDiffPct > 0 then
                    exptMissingStr = exptColor .. tostring(expDiffLevels) .. "|r"
                elseif expDiffPct < 0 then
                    exptMissingStr = exptColor .. tostring(expDiffLevels) .. "|r"
                else
                    exptMissingStr = "|cff00ff00" .. L["STATUS_OK"] .. "|r"
                end
                lines.line2 = SafeFormat(L["IDPS_LINE2_MOP"], hitColor, hitPct, hitReq, hitMissingStr, exptColor, exptPct, expCap, exptMissingStr)
            end

            -- Haste / Crit / Mastery
            local hastePct, hasteRating = 0, 0
            local critPct, critRating = 0, 0
            if isCaster then
                hastePct = GetCombatRatingBonus(CR_HASTE_SPELL) or 0
                hasteRating = GetCombatRating(CR_HASTE_SPELL) or 0
                critPct = 0
                local tmp = GetSpellCritChance(2) or 0
                for i=3,7 do local c = GetSpellCritChance(i) or 0 if c > tmp then tmp = c end end
                critPct = tmp
                critRating = GetCombatRating(CR_CRIT_SPELL) or 0
            else
                hastePct = GetCombatRatingBonus(CR_HASTE_MELEE) or 0
                hasteRating = GetCombatRating(CR_HASTE_MELEE) or 0
                critPct = GetCritChance() or 0
                critRating = GetCombatRating(CR_CRIT_MELEE) or 0
            end
            local masteryPct = 0
            if GetMasteryEffect then masteryPct = GetMasteryEffect() or 0 elseif GetMastery then masteryPct = GetMastery() or 0 end
            local masteryRating = (CR_MASTERY and GetCombatRating and (GetCombatRating(CR_MASTERY) or 0)) or 0

            lines.line3 = SafeFormat(L["IDPS_LINE3_MOP"], hastePct, hasteRating, critPct, critRating, masteryPct, masteryRating)

            return lines
        end
        
        -- Override race hit: Draenei self +1%, ignore aura
        function ITank.Data:GetRaceHitBonus()
            local _, raceEn = UnitRace("player")
            if raceEn == "Draenei" then return 1 end
            return 0
        end
        function ITank.Data:GetDraeneiAuraHitBonus()
            return 0
        end

        -- MoP specialization helpers
        function ITank.Data:GetMoPSpecIndex()
            if type(GetSpec) == "function" then
                local idx = GetSpec()
                if idx and idx > 0 then return idx end
            end
            -- Fallback: try inspect-style for player (may work on some builds)
            if type(GetInspectSpec) == "function" then
                local specID = GetInspectSpec("player")
                if specID and specID > 0 and type(GetSpecInfoByID) == "function" then
                    -- Map to a pseudo-index (not strictly needed if caller only needs name/role)
                    return 1
                end
            end
            return 1
        end
        function ITank.Data:GetMoPSpecInfo()
            local idx = (type(GetSpec) == "function") and GetSpec() or nil
            if idx and idx > 0 and type(GetSpecInfo) == "function" then
                local id, name, _, _, role = GetSpecInfo(idx)
                return idx, id, name, role
            end
            -- Fallback: try inspect-style on player
            if type(GetInspectSpec) == "function" and type(GetSpecInfoByID) == "function" then
                local specID = GetInspectSpec("player")
                if specID and specID > 0 then
                    local _, name, _, _, role = GetSpecInfoByID(specID)
                    return nil, specID, name, role
                end
            end
            return nil, nil, nil, nil
        end

        -- Helpers: role/spec-based rules
        local function IsHealerSpec(role)
            return role == "HEALER"
        end
        local function IsCasterSpec(classEn, specName, role)
            if IsHealerSpec(role) then return true end
            if classEn == "MAGE" or classEn == "WARLOCK" or classEn == "PRIEST" then return true end
            if classEn == "SHAMAN" and specName and (specName == "Elemental" or specName == "元素" or specName == "元素薩滿") then return true end
            if classEn == "DRUID" and specName and (specName == "Balance" or specName == "平衡" or specName == "平衡德魯伊") then return true end
            return false
        end
        function ITank.Data:GetMoPHitRequirement(classEn)
            local _, _, name, role = self:GetMoPSpecInfo()
            if IsHealerSpec(role) then return 0 end
            if IsCasterSpec(classEn, name, role) then return 15 end
            return 7.5
        end
        -- Override talent spec string for MoP: return spec name only
        local baseGetSpecStr = ITank.Data.GetTalentSpecInfoString
        function ITank.Data:GetTalentSpecInfoString()
            local _, _, name = self:GetMoPSpecInfo()
            return name or (ns.L and ns.L["UNKNOWN"] or "Unknown"), 0, name
        end

        -- Unit spec info for MoP (player or inspected unit)
        function ITank.Data:GetUnitSpecInfo_MoP(unit)
            unit = unit or "player"
            if unit == "player" then
                local idx = (type(GetSpec) == "function") and GetSpec() or nil
                if idx and idx > 0 and type(GetSpecInfo) == "function" then
                    local id, name, _, icon, role = GetSpecInfo(idx)
                    return idx, id, name, icon, role
                end
                -- Fallback: inspect-style even for player
                if type(GetInspectSpec) == "function" and type(GetSpecInfoByID) == "function" then
                    local specID = GetInspectSpec("player")
                    if specID and specID > 0 then
                        local _, name, _, icon, role = GetSpecInfoByID(specID)
                        return nil, specID, name, icon, role
                    end
                end
                return nil, nil, nil, nil, nil
            else
                if type(GetInspectSpec) == "function" and type(GetSpecInfoByID) == "function" then
                    local specID = GetInspectSpec(unit)
                    if specID and specID > 0 then
                        local _, name, _, icon, role = GetSpecInfoByID(specID)
                        return nil, specID, name, icon, role
                    end
                end
                return nil, nil, nil, nil, nil
            end
        end

        -- Tank spec detection for MoP
        local baseIsTankSpec = ITank.Data.IsTankSpec
        function ITank.Data:IsTankSpec()
            local _, _, _, role = self:GetMoPSpecInfo()
            if role == "TANK" then return true end
            return false
        end
    end
end

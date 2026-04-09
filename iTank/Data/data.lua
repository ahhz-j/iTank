-- iTank 数据与公式
-- 此文件包含 iTank 的数据表和计算公式

-- 确保命名空间存在
local addonName, ns = ...
ITank = ITank or {}
ITank.Data = {}
local L = ns.L or {}

-- ============================================================================
-- 0. 常量与辅助函数
-- ============================================================================

-- 战斗等级常量（后备）
local CR_HIT_MELEE = CR_HIT_MELEE or 6
local CR_HIT_SPELL = CR_HIT_SPELL or 8
local CR_CRIT_MELEE = CR_CRIT_MELEE or 9
local CR_CRIT_SPELL = CR_CRIT_SPELL or 11
local CR_HASTE_MELEE = CR_HASTE_MELEE or 18
local CR_HASTE_RANGED = CR_HASTE_RANGED or 19
local CR_HASTE_SPELL = CR_HASTE_SPELL or 20
local CR_HIT_RANGED = CR_HIT_RANGED or 7
local CR_EXPERTISE = CR_EXPERTISE or 24
local CR_ARMOR_PENETRATION = CR_ARMOR_PENETRATION or 25
local COMBAT_RATING_RESILIENCE_CRIT_TAKEN = COMBAT_RATING_RESILIENCE_CRIT_TAKEN or 15 --备用备查备清理

-- 辅助函数：计算防御技能提供的加成（未命中/躲闪/招架/格挡 %）
-- 每点防御技能提供 0.04% 的未命中、躲闪、招架、格挡。
-- 加成基于与等级*5（最大基础技能）的差值。
local function GetDodgeBlockParryChanceFromDefense()
    local base, modifier = UnitDefense("player")
    if not base then return 0 end
    local defense = base + modifier
    local level = UnitLevel("player") or 80
    return (defense - level * 5) * 0.04
end

-- 辅助函数：检查玩家是否为坦克专精
function ITank.Data:IsTankSpec()
    local _, class = UnitClass("player")
    local function GetPrimaryTalentTree()
        local maxPoints, index = 0, 0
        for i = 1, 3 do
            local _, _, _, _, points = GetTalentTabInfo(i)
            points = points or 0
            if points > maxPoints then
                maxPoints = points
                index = i
            end
        end
        return index
    end

    local tree = GetPrimaryTalentTree()

    if class == "PALADIN" and tree == 2 then return true end
    if class == "WARRIOR" and tree == 3 then return true end
    if class == "DEATHKNIGHT" and tree == 1 then return true end
    if class == "DRUID" and tree == 2 then
        -- 检查天赋树2（野性）中的“适者生存”
        local numTalents = GetNumTalents(2)
        for i = 1, numTalents do
            local name, _, _, _, rank = GetTalentInfo(2, i)
            if name == L["TALENT_SURVIVAL_OF_THE_FITTEST"] and rank > 0 then
                return true
            end
        end
    end

    return false
end

-- ============================================================================
-- 0. 游戏版本适配 (Game Version Adapter)
-- ============================================================================

ITank.Data.GameVersion = {
    Current = select(4, GetBuildInfo()) or 0,
    
    -- 已知版本列表
    Versions = {
        CLASSIC_ERA = 11508, -- 1.15.8 (经典怀旧服)
        TBC_ERA     = 20505, -- 2.5.5 (周年纪念服/TBC)
        WOTLK_TITAN = 30800, -- 3.80.0 (泰坦重铸, TOC: 30800)
        MOP_ERA     = 50503, -- 5.5.3 (熊猫人之谜怀旧服)
    },
    
    -- 功能特性开关
    Features = {
        ResilienceCritImmunity = false, -- 默认不提供免爆
    }
}

do
    local v = ITank.Data.GameVersion
    local cur = v.Current or 0
    local vers = v.Versions or {}
    v.IsClassic = cur < (vers.TBC_ERA or 20000)
    v.IsTBC = cur >= (vers.TBC_ERA or 20000) and cur < (vers.WOTLK_TITAN or 30000)
    v.IsWOTLK = cur >= (vers.WOTLK_TITAN or 30000) and cur < (vers.MOP_ERA or 50000)
    v.IsMOP = cur >= (vers.MOP_ERA or 50000) and cur < 60000
    ITank.Data.IsTBC = v.IsTBC
    ITank.Data.IsMOP = v.IsMOP
end

do
    local v = ITank.Data.GameVersion
    local cur = v.Current
    
    if v.IsTBC then
        v.Features.ResilienceCritImmunity = true
    elseif v.IsWOTLK then
        if cur >= 30800 then
            v.Features.ResilienceCritImmunity = false
        else
            v.Features.ResilienceCritImmunity = true
        end
    else
        v.Features.ResilienceCritImmunity = false
    end
end

-- 版本文本标签
function ITank.Data:GetGameVersionLabel()
    local v = self.GameVersion
    if not v then return "" end
    if v.IsMOP then return "MOP" end
    if v.IsWOTLK then return "Titan" end
    if v.IsTBC then return "TBC" end
    return "ERA"
end

-- ============================================================================
-- 1. 命中阈值数据
-- ============================================================================
-- [职业] = { [专精索引] = 阈值% } 或 默认阈值%
ITank.Data.HitCaps = {
    ["HUNTER"] = 8,
    ["ROGUE"] = 8, -- 毒药命中需要更高，通常显示物理命中
    ["WARRIOR"] = 8,
    ["DEATHKNIGHT"] = 14,
    ["MAGE"] = 14, -- 法系通常17%，但这可能包括团队buff，用户要求14%
    ["WARLOCK"] = 14,
    ["PRIEST"] = { [1] = 0, [2] = 0, [3] = 14 }, -- 1:戒律(奶), 2:神圣(奶), 3:暗影(法)
    ["PALADIN"] = { [1] = 0, [2] = 8, [3] = 8 }, -- 1:神圣(奶), 2:防护(物), 3:惩戒(物)
    ["SHAMAN"] = { [1] = 14, [2] = 8, [3] = 0 }, -- 1:元素(法), 2:增强(双修), 3:恢复(奶)
    ["DRUID"] = { [1] = 14, [2] = 8, [3] = 0 }, -- 1:平衡(法), 2:野性(物), 3:恢复(奶)
}

-- ============================================================================
-- 2. 套装物品数据
-- ============================================================================

-- 命中天赋配置
ITank.Data.HitTalentsConfig = {
    WARRIOR = {L["TALENT_PRECISION"]}, HUNTER = {L["TALENT_FOCUSED_AIM"]}, ROGUE = {L["TALENT_PRECISION"]},
    PRIEST = {L["TALENT_SHADOW_FOCUS"]}, DEATHKNIGHT = {L["TALENT_VIRULENCE"]},
    SHAMAN = { [1] = {L["TALENT_ELEMENTAL_PRECISION"]}, [2] = {L["TALENT_DUAL_WIELD_SPECIALIZATION"], L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"]} },
    MAGE = {L["TALENT_PRECISION_MAGE"]}, WARLOCK = {L["TALENT_SUPPRESSION"]}, DRUID = { [1] = {L["TALENT_BALANCE_OF_POWER"]} },
}

-- 针对萨满：拆分命中天赋为 近战/法系 两类
ITank.Data.ShSplitCache = { p1 = -1, p2 = -1, p3 = -1, melee = 0, spell = 0, init = false }
function ITank.Data:GetShamanTalentHitSplit()
    local L = ns.L or {}
    local gv = self.GameVersion or {}
    local build = select(4, GetBuildInfo()) or 0
    if gv.IsMOP or build >= 50000 then return 0, 0 end
    if type(GetTalentTabInfo) ~= "function" then return 0, 0 end
    local p1, _, _, _, t1 = GetTalentTabInfo(1)
    local p2, _, _, _, t2 = GetTalentTabInfo(2)
    local p3, _, _, _, t3 = GetTalentTabInfo(3)
    t1 = tonumber(t1) or 0; t2 = tonumber(t2) or 0; t3 = tonumber(t3) or 0
    local c = self.ShSplitCache
    if c.init and c.p1 == t1 and c.p2 == t2 and c.p3 == t3 then
        return c.melee, c.spell
    end
    local melee, spell = 0, 0
    if type(GetNumTalents) == "function" and type(GetTalentInfo) == "function" then
        for tab = 1, 3 do
            local num = GetNumTalents(tab)
            for i = 1, (num or 0) do
                local name, _, _, _, rank = GetTalentInfo(tab, i)
                rank = rank or 0
                if name == L["TALENT_DUAL_WIELD_SPECIALIZATION"] then
                    melee = melee + rank * 2
                elseif name == L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"] then
                    if rank > 0 then spell = spell + 6 end
                elseif name == L["TALENT_ELEMENTAL_PRECISION"] then
                    spell = spell + rank
                end
            end
        end
    end
    c.p1, c.p2, c.p3, c.melee, c.spell, c.init = t1, t2, t3, melee, spell, true
    return melee, spell
end

function ITank.Data:GetDeathKnightTalentHitSplit(treeIndex)
    local spell = self:GetTalentHitBonus("DEATHKNIGHT", treeIndex)
    return 0, spell
end

-- 颜色定义
ITank.Data.Colors = {
    Red = "|cFFFF0000",
    Green = "|cFF00FF00",
    Olive = "|cFF6B8E23",
    DarkGreen = "|cFF006400",
    Orange = "|cFFFF4500",
    EpicPurple = "|cffa335ee",
    White = "|cFFFFFFFF"
}

-- ============================================================================
-- 3. 字体配置
-- ============================================================================
ITank.Data.FontConfig = {
    DefaultFace = STANDARD_TEXT_FONT, -- 若为空则由 GetUIFontFace 回退
    DefaultSize = 14,
    DefaultFlags = "OUTLINE",
}

function ITank.Data:GetUIFontFace()
    local face = (self.FontConfig and self.FontConfig.DefaultFace) or STANDARD_TEXT_FONT
    if not face and GameFontNormal and GameFontNormal.GetFont then
        local f = GameFontNormal:GetFont()
        if type(f) == "string" and #f > 0 then face = f end
    end
    return face or "Fonts\\ARIALN.TTF"
end

function ITank.Data:GetUIFontDefaults()
    local size = (self.FontConfig and self.FontConfig.DefaultSize) or 14
    local flags = (self.FontConfig and self.FontConfig.DefaultFlags) or "OUTLINE"
    return self:GetUIFontFace(), size, flags
end

-- 初始化允许的套装表（内存友好：范围表+单点表，不展开为每ID的映射）
local AllowedSetSingles = {}  -- { [setID] = totalCount }
local AllowedSetRanges = {}   -- { {s=begin, e=end, c=totalCount}, ... }
local function addSets(data, count)
    if type(data) == "table" then
        for _, id in ipairs(data) do AllowedSetSingles[id] = count end
    elseif type(data) == "number" then
        AllowedSetSingles[data] = count
    end
end
local function addRange(s, e, c) table.insert(AllowedSetRanges, { s = s, e = e, c = c }) end
if type(ITank_LoadSets) == "function" then ITank_LoadSets(addSets, addRange) end
local function GetAllowedSetCount(setID)
    local v = AllowedSetSingles[setID]
    if v then return v end
    for i = 1, #AllowedSetRanges do
        local r = AllowedSetRanges[i]
        if setID >= r.s and setID <= r.e then return r.c end
    end
    return nil
end

-- 获取天赋命中加成
function ITank.Data:GetTalentHitBonus(classEn, treeIndex)
    local bonus = 0
    local L = ns.L or {}
    local config = self.HitTalentsConfig[classEn]
    if not config then return 0 end
    local gv = self.GameVersion or {}
    local build = select(4, GetBuildInfo()) or 0
    if gv.IsMOP or build >= 50000 then
        return 0
    end
    if type(GetNumTalents) ~= "function" or type(GetTalentInfo) ~= "function" then
        return 0
    end
    
    local talentsToCheck = {}
    if classEn == "SHAMAN" then
        if type(config[1]) == "table" then
            for i = 1, 3 do
                if type(config[i]) == "table" then
                    for _, n in ipairs(config[i]) do table.insert(talentsToCheck, n) end
                end
            end
        else
            talentsToCheck = config
        end
    else
        if type(config[1]) == "string" then
            talentsToCheck = config
        elseif config[treeIndex] then
            talentsToCheck = config[treeIndex]
        end
    end
    
    local perRankMap = ITank.Data.HitTalentPerRank or {}
    for _, talentName in ipairs(talentsToCheck) do
        for t = 1, 3 do
            local okNum, numTalents = pcall(GetNumTalents, t)
            if not okNum or type(numTalents) ~= "number" then
                return 0
            end
            for i = 1, numTalents do
                local okInfo, name, _, _, _, rank = pcall(function() return GetTalentInfo(t, i) end)
                if not okInfo then
                    return 0
                end
                if name == talentName then
                    if talentName == L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"] then
                        if (rank or 0) > 0 then bonus = bonus + 6 end
                    else
                        local perRank = 1
                        if perRankMap and perRankMap[talentName] then
                            perRank = perRankMap[talentName]
                        else
                            if talentName == L["TALENT_DUAL_WIELD_SPECIALIZATION"] then perRank = 2 end
                            if talentName == L["TALENT_BALANCE_OF_POWER"] then perRank = 2 end
                        end
                        bonus = bonus + (rank * perRank)
                    end
                end
            end
        end
    end
    return bonus
end

ITank.Data.SetCache = { built = false, setString = "", itemSets = nil }
function ITank.Data:InvalidateSetCache()
    local c = self.SetCache
    c.built = false
    c.setString = ""
    c.itemSets = nil
end
function ITank.Data:RefreshSetCache()
    local needString = iTankDB and iTankDB.ShowSets
    local needItemSets = iTankDB and iTankDB.ShowSetHit
    if not needString and not needItemSets then
        self:InvalidateSetCache()
        return
    end
    local itemSets = {}
    for i = 1, 18 do
        local link = GetInventoryItemLink("player", i)
        if link then
            local _, _, _, iLevel, _, _, _, _, _, _, _, _, _, _, _, setID = GetItemInfo(link)
            if setID and setID > 0 then
                local maxT = GetAllowedSetCount(setID)
                if maxT then
                    if not itemSets[setID] then
                        local name = GetItemSetInfo(setID)
                        local prefix = ""
                        if iLevel then
                            if iLevel >= 210 and iLevel <= 215 then prefix = "T1"
                            elseif iLevel >= 251 and iLevel <= 264 then prefix = "T2"
                            elseif (iLevel >= 236 and iLevel <= 241) or (iLevel >= 276 and iLevel <= 285) then prefix = "T6"
                            elseif iLevel >= 216 and iLevel <= 222 then prefix = "T5"
                            elseif iLevel >= 223 and iLevel <= 228 then prefix = "T7"
                            elseif iLevel >= 229 and iLevel <= 235 then prefix = "T9"
                            elseif iLevel >= 242 and iLevel <= 248 then prefix = "T8"
                            elseif iLevel >= 249 and iLevel <= 255 then prefix = "T4"
                            elseif iLevel >= 265 and iLevel <= 268 then prefix = "T2.5"
                            elseif iLevel >= 269 and iLevel <= 275 then prefix = "T10"
                            end
                        end
                        if prefix ~= "" then name = "[" .. prefix .. "]" .. (name or "Set") end
                        itemSets[setID] = { name = name, count = 1, total = maxT }
                    else
                        itemSets[setID].count = itemSets[setID].count + 1
                    end
                end
            end
        end
    end
    local setString = ""
    if needString then
        local setOut = {}
        for _, info in pairs(itemSets) do
            setOut[#setOut + 1] = string.format("%s:%d/%d", info.name, info.count, info.total)
        end
        if #setOut > 0 then
            setString = "  " .. self.Colors.EpicPurple .. table.concat(setOut, "  ") .. "|r"
        end
    end
    local c = self.SetCache
    c.setString = setString
    c.itemSets = needItemSets and itemSets or nil
    c.built = true
end

function ITank.Data:GetSetInfo()
    local needString = iTankDB and iTankDB.ShowSets
    local needItemSets = iTankDB and iTankDB.ShowSetHit
    if not needString and not needItemSets then
        return "", nil
    end
    local c = self.SetCache
    if not c.built then self:RefreshSetCache() end
    return c.setString or "", (needItemSets and c.itemSets or nil)
end

-- 获取法师T1套装命中加成
function ITank.Data:GetMageT1HitBonus(classEn, itemSets)
    if classEn ~= "MAGE" then return 0 end
    if itemSets then
        for id = 1991, 2009 do
            if itemSets[id] and itemSets[id].count >= 2 then return 1 end
        end
        return 0
    end
    local count = 0
    for i = 1, 18 do
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink then
            local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, setID = GetItemInfo(itemLink)
            if setID and setID >= 1991 and setID <= 2009 then
                count = count + 1
            end
        end
    end
    if count >= 2 then return 1 end
    return 0
end

-- 获取种族命中加成
function ITank.Data:GetRaceHitBonus()
    local _, raceEn = UnitRace("player")
    if ITank and ITank.Data and ITank.Data.IsTBC then
        if raceEn == "Draenei" then return 1 end
        return 0
    else
        if raceEn == "Draenei" then return 2 end
        return 0
    end
end



-- ============================================================================
-- 3. iDPS 评分公式
-- ============================================================================
-- 常量定义
local RATING_CRIT = 45.91 --备用备查备清理
local RATING_HASTE_MELEE = 25.21 --备用备查备清理
local RATING_HASTE_RANGED = 32.79 --备用备查备清理
local RATING_ARP = 13.99 --备用备查备清理
local RATING_SPELL_HIT = 26.23 --备用备查备清理
local RATING_HIT_MELEE = 32.79 --备用备查备清理
local RATING_EXPERTISE = 8.1974 --备用备查备清理

-- 辅助：获取主天赋树索引及名称
local function GetMainTalentTreeInfo()
    local maxPoints = -1
    local mainTree = 1
    local treeName = ""
    for i = 1, 3 do
        local _, name, _, _, pointsSpent = GetTalentTabInfo(i)
        pointsSpent = tonumber(pointsSpent) or 0
        if pointsSpent > maxPoints then
            maxPoints = pointsSpent
            mainTree = i
            treeName = name
        end
    end
    return mainTree, treeName
end

function ITank.Data:CalculateiDPSScore(itemSets)
    local class = UnitClass("player") -- 返回本地化职业名称
    local _, classEn = UnitClass("player") -- 返回英文职业名称 (例如 "PALADIN")
    
    -- 1. 获取基础属性
    local str = UnitStat("player", 1) -- 力量
    local agi = UnitStat("player", 2) -- 敏捷
    local int = UnitStat("player", 4) -- 智力
    local spi = UnitStat("player", 5) -- 精神
    
    -- 2. 获取战斗属性
    local hitRating = GetCombatRating(CR_HIT_MELEE)
    local hitBonus = GetCombatRatingBonus(CR_HIT_MELEE) -- 公式中未使用，但保留供参考 --备用备查备清理
    
    local critRating = GetCombatRating(CR_CRIT_MELEE)
    local critChance = GetCritChance() --备用备查备清理
    
    local hasteRating = GetCombatRating(CR_HASTE_MELEE)
    
    local expertiseRating = GetCombatRating(CR_EXPERTISE)
    local expertise = GetExpertise() --备用备查备清理
    
    local arpRating = GetCombatRating(CR_ARMOR_PENETRATION)
    
    local baseAP, posAP, negAP = UnitAttackPower("player")
    local ap = baseAP + posAP + negAP
    
    -- 3. 获取法系/远程属性
    local sp = GetSpellBonusDamage(2) -- 神圣/通用法术强度
    
    local baseRAP, posRAP, negRAP = UnitRangedAttackPower("player")
    local rap = baseRAP + posRAP - negRAP
    
    local rangedHitRating = GetCombatRating(CR_HIT_RANGED)
    local rangedCritChance = GetRangedCritChance()
    local rangedHasteRating = GetCombatRating(CR_HASTE_RANGED)
    
    -- 修正：使用等级而不是百分比计算法术命中
    local spellHitRating = GetCombatRating(CR_HIT_SPELL)
    local spellCritRating = GetCombatRating(CR_CRIT_SPELL)
    local spellHasteRating = GetCombatRating(CR_HASTE_SPELL)
    
    -- 4. 计算加成（天赋、种族、套装）
    local mainTree, talentName = GetMainTalentTreeInfo()
    local talentHitBonus = self:GetTalentHitBonus(classEn, mainTree)
    local meleeTalentHitBonus, spellTalentHitBonus = talentHitBonus, talentHitBonus
    local shMeleeBonus, shSpellBonus = 0, 0
    if classEn == "SHAMAN" then
        shMeleeBonus, shSpellBonus = self:GetShamanTalentHitSplit()
        meleeTalentHitBonus, spellTalentHitBonus = shMeleeBonus, shSpellBonus
    elseif classEn == "DEATHKNIGHT" then
        meleeTalentHitBonus, spellTalentHitBonus = self:GetDeathKnightTalentHitSplit(mainTree)
    end
    
    local raceHit = self:GetRaceHitBonus()
    local setHitBonus = self:GetMageT1HitBonus(classEn, itemSets)
    
    local totalHitBonusPct = talentHitBonus + raceHit + setHitBonus
    
    -- 转换常量
    local RATING_HIT_MELEE = 32.79
    local RATING_SPELL_HIT = 26.23
    
    -- 将加成添加到等级中
    if classEn == "SHAMAN" then
        local meleePct = (shMeleeBonus + raceHit) -- 套装仅对法师处理
        local spellPct = (shSpellBonus + raceHit) + setHitBonus
        if meleePct > 0 then
            local added = meleePct * RATING_HIT_MELEE
            hitRating = hitRating + added
            rangedHitRating = rangedHitRating + added
        end
        if spellPct > 0 then
            local added = spellPct * RATING_SPELL_HIT
            spellHitRating = spellHitRating + added
        end
    else
        local meleePct = meleeTalentHitBonus + raceHit + setHitBonus
        local spellPct = spellTalentHitBonus + raceHit + setHitBonus
        if meleePct > 0 then
            local addedMeleeRating = meleePct * RATING_HIT_MELEE
            hitRating = hitRating + addedMeleeRating
            rangedHitRating = rangedHitRating + addedMeleeRating
        end
        if spellPct > 0 then
            local addedSpellRating = spellPct * RATING_SPELL_HIT
            spellHitRating = spellHitRating + addedSpellRating
        end
    end
    
    -- 5. 命中溢出处理（上限为264等级等效值）
    -- 参考源代码：超出部分按 0.1 分计算
    local dpsPoint = 0
    
    if hitRating > 264 then
        dpsPoint = dpsPoint + (hitRating - 264) * 0.1
    end
    
    if spellHitRating > 264 then
        dpsPoint = dpsPoint + (spellHitRating - 264) * 0.1
    end
    
    if rangedHitRating > 264 then
        dpsPoint = dpsPoint + (rangedHitRating - 264) * 0.1
    end
    
    -- 6. 职业特定公式
    -- 修正：使用 spellHitRating 替代 spellHitPercent
    if classEn == "PALADIN" then
        dpsPoint = dpsPoint + (str * 2.53 + agi * 1.13 + int * 0.15 + hasteRating * 1.44 + critRating * 1.16 + arpRating * 0.76 + expertiseRating * 1.80 + hitRating * 1.96 + sp * 0.32 + ap * 1)
        
    elseif classEn == "WARRIOR" then
        dpsPoint = dpsPoint + (str * 2.72 + agi * 1.82 + hasteRating * 1.72 + critRating * 2.12 + arpRating * 2.17 + expertiseRating * 2.55 + hitRating * 0.79 + sp * 0.00 + ap * 1)
        
    elseif classEn == "DEATHKNIGHT" then
        local isFrost = (talentName == L["SPEC_FROST"] or mainTree == 2)
        if isFrost then
            -- 冰DK (高破甲)
            dpsPoint = dpsPoint + (str * 3.22 + agi * 0.62 + hasteRating * 0.77 + critRating * 0.76 + arpRating * 1.85 + expertiseRating * 1.5 + hitRating * 1.92 + sp * 0.00 + ap * 1)
        else
            -- 邪DK (高急速)
            dpsPoint = dpsPoint + (str * 3.22 + agi * 0.62 + hasteRating * 1.85 + critRating * 0.76 + arpRating * 0.77 + expertiseRating * 1.5 + hitRating * 1.92 + sp * 0.00 + ap * 1)
        end
        
    elseif classEn == "HUNTER" then
        dpsPoint = dpsPoint + (str * 0.00 + agi * 2.65 + int * 1.10 + hasteRating * 1.39 + critRating * 1.50 + arpRating * 1.32 + expertiseRating * 0.00 + hitRating * 0.00 + rap * 1.00 + rangedHitRating * 2 + rangedCritChance * 1.5 + rangedHasteRating * 1.39)
        
    elseif classEn == "SHAMAN" then
        -- 增强 (天赋树2)
        if talentName == L["SPEC_ENHANCEMENT"] or mainTree == 2 then
             dpsPoint = dpsPoint + (str * 1.10 + agi * 1.59 + int * 1.48 + hasteRating * 1.61 + critRating * 0.81 + arpRating * 0.48 + expertiseRating * 0.00 + hitRating * 1.38 + sp * 1.13 + ap * 1)
        else
            -- 元素/恢复
            dpsPoint = dpsPoint + (int * 0.22 + spi * 0.0 + sp * 1.00 + spellHitRating * 0.0 + spellCritRating * 0.67 + spellHasteRating * 1.29)
        end
        
    elseif classEn == "ROGUE" then
        dpsPoint = dpsPoint + (str * 1.14 + agi * 1.86 + hasteRating * 1.48 + critRating * 1.32 + arpRating * 0.84 + expertiseRating * 0.98 + hitRating * 1.39 + ap * 1)
        
    elseif classEn == "DRUID" then
        -- 平衡 (天赋树1)
        if talentName == L["SPEC_BALANCE"] or mainTree == 1 then
            dpsPoint = dpsPoint + (int * 0.48 + spi * 0.42 + sp * 1.00 + spellHitRating * 0.38 + spellCritRating * 0.58 + spellHasteRating * 0.94)
        else
            -- 野性 (天赋树2)
            dpsPoint = dpsPoint + (str * 2.40 + agi * 2.39 + int * 0.00 + hasteRating * 1.83 + critRating * 2.23 + arpRating * 2.08 + expertiseRating * 2.44 + hitRating * 2.51 + ap * 1)
        end
        
    elseif classEn == "MAGE" then
        dpsPoint = dpsPoint + (int * 0.48 + spi * 0.42 + sp * 1.00 + spellHitRating * 0.38 + spellCritRating * 0.58 + spellHasteRating * 0.94)
        
    elseif classEn == "WARLOCK" then
        dpsPoint = dpsPoint + (int * 0.18 + spi * 0.54 + sp * 1.00 + spellHitRating * 0.93 + spellCritRating * 0.53 + spellHasteRating * 0.81)
        
    elseif classEn == "PRIEST" then
        dpsPoint = dpsPoint + (int * 0.11 + spi * 0.47 + sp * 1.00 + spellHitRating * 0.87 + spellCritRating * 0.74 + spellHasteRating * 1.65)
        
    else
        dpsPoint = 5 -- 未知职业的后备方案
    end
    
    return math.floor(dpsPoint)
end

-- ============================================================================
-- 4. iTank 评分与防御属性
-- ============================================================================

-- 辅助函数：四舍五入
local function round(num, idp)
    local mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function ITank.Data:GetDefenseStats()
    local data = {}
    local classFilename, classId = UnitClassBase("player") -- classFilename --备用备查备清理
    local _, classEn = UnitClass("player")
    
    -- 1. 基础属性
    local str = UnitStat("player", 1) -- 力量
    local agi = UnitStat("player", 2) -- 敏捷
    local sta = UnitStat("player", 3) -- 耐力
    local maxh = UnitHealthMax("player")
    local baseArmor, effectiveArmor = UnitArmor("player") -- baseArmor --备用备查备清理
    
    -- 2. 防御等级
    local baseDefense, armorDefense = UnitDefense("player") --备用备查备清理
    local pdef = baseDefense + armorDefense -- 总防等
    
    -- 3. 四维 (Miss, Dodge, Parry, Block)
    local def = GetDodgeBlockParryChanceFromDefense() -- 防御技能提供的加成
    local miss = def + 5 -- 未命中
    local dodge = GetDodgeChance() -- 闪躲
    local parry = GetParryChance() -- 招架
    local block = GetBlockChance() -- 格挡
    local bv = GetShieldBlock() -- 格挡值
    
    local avoidance = miss + dodge + parry
    local total = miss + dodge + parry + block -- 圆桌覆盖率
    local ct = round(total - 102.4, 2) -- 溢出/缺口
    
    -- 4. 命中 (Hit)
    -- 注意：reference 中 hitrating 是指最终命中百分比
    local hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE) -- 装备提供的命中%
    if classEn == "DEATHKNIGHT" then
        local mode = (iTankDB and iTankDB.DKHitMode) or 2
        if mode == 1 then -- Physical
             hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE)
        else -- Spell
             hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL) -- DK用得法系命中
        end
    end
    
    -- 天赋命中加成
    local primaryTree, talentName, prePoints = 1, L["NONE"], -1
    if ITank and ITank.Data and ITank.Data.IsMOP and ITank.Data.GetMoPSpecIndex then
        primaryTree = ITank.Data:GetMoPSpecIndex()
        talentName = L["UNKNOWN"]
    else
        for i = 1, 3 do
            local _, name, _, _, points = GetTalentTabInfo(i)
            points = tonumber(points) or 0
            if points > prePoints then
                prePoints, primaryTree, talentName = points, i, name or L["UNKNOWN"] -- talentName --备用备查备清理
            end
        end
    end
    local talentPoints = self:GetTalentHitBonus(classEn, primaryTree)
    local meleeTalentPoints, spellTalentPoints = talentPoints, talentPoints
    if classEn == "SHAMAN" then
        meleeTalentPoints, spellTalentPoints = self:GetShamanTalentHitSplit()
    elseif classEn == "DEATHKNIGHT" then
        meleeTalentPoints, spellTalentPoints = self:GetDeathKnightTalentHitSplit(primaryTree)
    end
    if classEn == "SHAMAN" then
        -- 萨满按专精路径显示命中：增强=近战，其他=法术
        if primaryTree == 2 then
            hitRatingBonus = GetCombatRatingBonus(CR_HIT_MELEE)
        else
            hitRatingBonus = GetCombatRatingBonus(CR_HIT_SPELL)
        end
    end
    
    -- 种族命中加成 (德莱尼)
    local raceHit = self:GetRaceHitBonus()
    
    local auraHit = 0
    if ITank and ITank.Data then
        if ITank.Data.IsMOP then
            auraHit = 0
        elseif ITank.Data.GetDraeneiAuraHitBonus then
            local _, raceEn = UnitRace("player")
            auraHit = ITank.Data:GetDraeneiAuraHitBonus() or 0
            if ITank.Data.IsTBC and raceEn == "Draenei" then
                auraHit = 0
            end
        end
    end
    local finalHitPercent = hitRatingBonus + talentPoints + raceHit + auraHit
    if classEn == "SHAMAN" then
        if primaryTree == 2 then
            finalHitPercent = hitRatingBonus + meleeTalentPoints + raceHit + auraHit
        else
            finalHitPercent = hitRatingBonus + spellTalentPoints + raceHit + auraHit
        end
    elseif classEn == "DEATHKNIGHT" then
        local mode = (iTankDB and iTankDB.DKHitMode) or 2
        if mode == 1 then
            finalHitPercent = hitRatingBonus + meleeTalentPoints + raceHit + auraHit
        else
            finalHitPercent = hitRatingBonus + spellTalentPoints + raceHit + auraHit
        end
    end
    
    -- 命中阈值
    local hitReq = 8
    local hitRatingPerPercent = 32.789
    if classEn == "DEATHKNIGHT" then
        local mode = (iTankDB and iTankDB.DKHitMode) or 2
        if mode == 1 then
            hitReq = 8
        else
            hitReq = 14
        end
    end
    do
        local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
        if classEn == "SHAMAN" then
            if primaryTree == 2 then
                hitRatingPerPercent = ratings.MeleeHit or hitRatingPerPercent
            else
                hitRatingPerPercent = ratings.SpellHit or hitRatingPerPercent
            end
        elseif classEn == "DEATHKNIGHT" then
            local mode = (iTankDB and iTankDB.DKHitMode) or 2
            if mode == 1 then
                hitRatingPerPercent = ratings.MeleeHit or hitRatingPerPercent
            else
                hitRatingPerPercent = ratings.SpellHit or hitRatingPerPercent
            end
        else
            hitRatingPerPercent = ratings.MeleeHit or hitRatingPerPercent
        end
        if ITank and ITank.Data and ITank.Data.HitCaps and classEn ~= "DEATHKNIGHT" then
            local hc = ITank.Data.HitCaps[classEn]
            if type(hc) == "number" then
                hitReq = hc
            elseif type(hc) == "table" then
                hitReq = hc[primaryTree] or hitReq
            end
        end
    end
    
    local missingHitLevel = math.floor((hitReq - finalHitPercent) * hitRatingPerPercent)
    
    -- 5. 精准 (Expertise)
    local expt = GetExpertise() or 0
    local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
    local expPerSkill = ratings.Expertise or 8.1974
    local expCapSkill = 26
    if ITank and ITank.Data then
        if ITank.Data.IsTBC then
            expCapSkill = 6.5
        elseif ITank.Data.IsMOP then
            expCapSkill = 15
        end
    end
    local missExp = math.floor(math.max(0, expCapSkill - expt) * expPerSkill)
    
    -- 6. 免暴需求 (Crit Immunity)
    local resil = GetCombatRatingBonus(15) or 0 -- 韧性免暴% (15: CR_CRIT_TAKEN_MELEE)
    
    -- 版本适配检查
    if not ITank.Data.GameVersion.Features.ResilienceCritImmunity then
        resil = 0
    end
    
    local defneed = 0 -- 所需防等（点数）
    local resilneed = 0 -- 所需韧性等级（rating）
    local Cr = 0 -- 还需免暴 (小数: 0.01 = 1%)
    
    if classId ~= 11 then -- 非德鲁伊
        -- 参考第115行：Cr=(5+0.04*15-(pdef-400)*0.04)/100
        -- Cr 是小数。
        local baseDef = 400
        if ITank and ITank.Data and ITank.Data.IsTBC then
            local plv = UnitLevel("player") or 70
            baseDef = plv * 5
        end
        local defReduction = (pdef - baseDef) * 0.04 -- %
        local remainCrit = 5.6 - defReduction - resil -- %
        if remainCrit < 0 then remainCrit = 0 end
        Cr = remainCrit / 100
        if Cr > 0 then
            -- 需要的防御技能（点数）
            defneed = remainCrit / 0.04
            -- 需要的韧性等级
            if ITank.Data.GameVersion.Features.ResilienceCritImmunity then
                local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
                local resilPerPercent = ratings.ResilCrit or 39.4
                resilneed = round(remainCrit * resilPerPercent, 0)
            end
        end
    end
    
    -- 修正：实际上我们应该计算剩余需要的免暴
    -- Crit Chance = 5.6% - DefReduction - ResilReduction
    -- 但严格遵循参考：
    if classId ~= 11 then
        -- 为EHP逻辑重新计算Cr？不，已经完成了。
        -- 但注意：上面的Cr没有减去韧性。
        -- 如果我有韧性，Cr应该更低？
        -- 参考逻辑：Cr仅由防御计算。
        -- 韧性被视为替代路径 (resilneed)。
    end
    
    -- 7. 护甲减伤
    local level = UnitLevel("player")
    local bossLevel = 83
    if ITank and ITank.Data and ITank.Data.GetBossLevelForDefense then
        bossLevel = ITank.Data:GetBossLevelForDefense(level)
    else
        if level == 80 then bossLevel = 83 else bossLevel = level + 3 end
    end
    
    -- 公式：ar / (ar + 467.5 * level - 22167.5)
    -- 参考使用的是设置为83的level变量。
    local dr = effectiveArmor / (effectiveArmor + 467.5 * bossLevel - 22167.5)
    if dr > 0.75 then dr = 0.75 end
    
    -- 8. 有效生命 (EHP)
    local hopeh = 0
    local crush = 0 -- 碾压几率（通常防御达标为0，但如果低防御则严格为15%... WLK移除防御达标后的碾压？还是高3级？）
    -- WLK：如果防御技能满了，团队BOSS的碾压被移除了？还是简单地移除了？
    -- 参考设置 crush=0。
    
    local Natt = 0 -- 普通攻击几率
    local dredDmg = 0 -- 伤害减免
    local totalDmg = 0 -- 总预期伤害
    local finblock = block / 100
    
    -- 圆桌理论逻辑
    local tmpCr = 1.024 - total / 100 -- 距离102.4%的差距
    local uncrushValue = nil
    if ITank and ITank.Data and ITank.Data.IsTBC and (classId == 1 or classId == 2) then
        -- 免碾差值： (Miss + Dodge + Parry + Block) - 102.4
        -- 正值达标，负值未达标
        uncrushValue = total - 102.4
    end
    local classdr = 0 -- 职业伤害减免
    if classId == 1 then classdr = 0.1 end -- 战士 (防御姿态)
    if classId == 2 then classdr = 0.116 end -- 圣骑士 (正义之怒 + 天赋?)
    if classId == 6 then classdr = 0.126 end -- DK (冰霜脸 + ?)
    if classId == 11 then classdr = 0.12 end -- 德鲁伊 (熊形态 + ?)
    
    -- 调整 Cr 以适应圆桌覆盖？
    -- 参考第148行：if tmpCr < Cr then Cr = tmpCr end
    -- 这意味着如果我们被挤出圆桌，暴击几率会降低？
    -- 实际上 Cr（暴击几率）是圆桌的一部分。
    -- 如果免伤 + 格挡很高，暴击会被挤出吗？
    -- 是的，暴击通常在圆桌的末端（在未命中、躲闪、招架、格挡之后？）。
    -- 实际顺序是：未命中、躲闪、招架、偏斜、格挡、暴击、碾压、命中。
    -- 如果未命中+躲闪+招架+格挡 > 100，暴击会被挤出吗？
    -- 参考逻辑：if tmpCr < Cr then Cr = tmpCr end。
    -- tmpCr 是 1.024 - total/100 -> 102.4% - (Miss+Dodge+Parry+Block)%。
    -- 如果圆桌满了 (total > 102.4)，tmpCr < 0。
    -- 所以 Cr 变成负数？
    -- 参考第155行：if Cr<=0 then Cr = 0 end。
    -- 所以是的，满圆桌会挤出暴击。
    
    if tmpCr < Cr then Cr = tmpCr end
    if Cr < 0 then Cr = 0 end
    
    Natt = 1.024 - Cr - crush - total / 100
    if Natt < 0 then Natt = 0 end
    
    if (avoidance + block) > 102.4 then 
        finblock = (102.4 - avoidance) / 100 
        if finblock < 0 then finblock = 0 end
    end
    
    dredDmg = 43000 * (1 - dr) * (1 - classdr) -- 假设 43000 原始伤害
    totalDmg = dredDmg * (2 * Cr + Natt) + (dredDmg - bv) * finblock
    
    -- 熊调整（野蛮防御？还是厚皮？）
    -- 参考第160行：if classId==11 ... dredDmg = dredDmg - crit/100 * AP * 0.25 ... 野蛮防御？
    if classId == 11 then
        local baseAP, posAP, negAP = UnitAttackPower("player")
        local AP = baseAP + posAP + negAP
        local crit = GetCritChance()
        dredDmg = dredDmg - (crit / 100 * AP * 0.25) -- 野蛮防御估算？
        totalDmg = dredDmg * (2 * Cr + Natt) -- 熊不格挡
    end
    
    if totalDmg > 0 then
        hopeh = round(maxh / (totalDmg / 43000), 2) -- 相对于原始伤害的有效生命
    else
        hopeh = maxh -- 无限EHP？仅作为后备
    end
    
    -- 9. iTank Score
    local iTankPercent = (str * 3.5 + agi * 10 + sta * 16 + effectiveArmor * 0.15 + avoidance * 250 + block * 120 + finalHitPercent * 8 + pdef * 28 + bv * 5.5 + maxh * 2.5) / 20
    
    if Cr > 0 then
        iTankPercent = iTankPercent * 0.8 -- 未免暴的惩罚
    else
        iTankPercent = iTankPercent * 1.1 -- 免暴的奖励
    end
    
    iTankPercent = math.floor(iTankPercent)
    
    -- 存储结果
    data.miss = miss
    data.dodge = dodge
    data.parry = parry
    data.block = block
    data.avoidance = avoidance
    data.total = total
    data.ct = ct
    if uncrushValue ~= nil then
        data.uncrush = round(uncrushValue, 2)
    end
    
    data.pdef = pdef
    data.defneed = defneed
    data.resil = resil
    data.resilneed = resilneed
    data.Cr = Cr
    
    data.finalHitPercent = finalHitPercent
    data.hitReq = hitReq
    data.missingHitLevel = missingHitLevel
    
    data.expt = round(expt, 1)
    data.missExp = missExp
    
    data.effectiveArmor = effectiveArmor
    data.dr = dr
    
    data.bv = bv
    data.hopeh = hopeh
    data.iTankScore = iTankPercent
    
    return data
end

-- 兼容性包装器（如果需要）
function ITank.Data:CalculateiTankScore() --备用备查备清理
    local data = self:GetDefenseStats() --备用备查备清理
    return data.iTankScore --备用备查备清理
end --备用备查备清理

-- ============================================================================
-- 5. UI数据提供者
-- ============================================================================

-- 获取基础信息数据
function ITank.Data:GetBasicInfo()
    local info = {}
    
    -- 第1行
    info.realm = GetRealmName()
    
    -- 职业颜色
    local _, classFilename = UnitClass("player")
    local r, g, b = 1, 0.75, 0.75 -- 默认
    if classFilename and RAID_CLASS_COLORS[classFilename] then
        local color = RAID_CLASS_COLORS[classFilename]
        r, g, b = color.r, color.g, color.b
    end
    info.classColor = {r, g, b}
    
    -- 第2行
    info.name = UnitName("player")
    info.className = UnitClass("player")
    info.talentInfo = self:GetTalentSpecInfoString()
    
    -- 第3行
    info.race = UnitRace("player")
    info.level = UnitLevel("player")
    info.hp = UnitHealthMax("player")
    info.power = UnitPowerMax("player")
    
    return info
end

-- 获取天赋专精信息字符串
function ITank.Data:GetTalentSpecInfoString()
    local maxPoints = 0
    local specName = L["NONE"]
    local t1, t2, t3 = 0, 0, 0
    local specIndex = 1
    
    -- 经典怀旧服通常有3个天赋树
    for i = 1, 3 do
        local _, name, _, _, points = GetTalentTabInfo(i)
        points = tonumber(points) or 0
        if i == 1 then t1 = points end
        if i == 2 then t2 = points end
        if i == 3 then t3 = points end
        
        if points > maxPoints then
            maxPoints = points
            specName = name
            specIndex = i
        end
    end
    
    return string.format("%s %d/%d/%d", specName or L["UNKNOWN"], t1, t2, t3), specIndex, specName
end

-- 获取DPS面板文本行
function ITank.Data:GetDPSPanelText()
    local lines = { line1 = "", line2 = "", line3 = "" }
    local L = ns.L or {}
    
    local function SafeFormat(fmt, ...)
        if not fmt then return "Missing Format String" end
        local status, res = pcall(string.format, fmt, ...)
        if status then return res end
        return "Format Error: " .. tostring(res)
    end
    
    -- 获取套装信息
    local setString, itemSets = self:GetSetInfo()
    
    -- 第1行：iDPS版本、评分、套装
    local score = self:CalculateiDPSScore(itemSets)
    lines.line1 = SafeFormat(L["IDPS_SCORE_FMT"], score, setString)
    
    -- 获取属性
    local Strength = UnitStat("player", 1) or 0
    local Agility = UnitStat("player", 2) or 0
    local Stamina = UnitStat("player", 3) or 0 --备用备查备清理
    local Intellect = UnitStat("player", 4) or 0
    local Spirit = UnitStat("player", 5) or 0
    
    -- 获取次要属性
    local Hit = GetCombatRatingBonus(CR_HIT_MELEE) or 0
    local rangedHitPercent = GetCombatRatingBonus(CR_HIT_RANGED) or 0
    local spellHitPercent = GetCombatRatingBonus(CR_HIT_SPELL) or 0
    
    local Haste = GetCombatRatingBonus(CR_HASTE_MELEE) or 0
    local Crit = GetCritChance() or 0
    local Expertise = math.floor(GetExpertise() or 0)
    local ArP = GetCombatRatingBonus(CR_ARMOR_PENETRATION) or 0
    
    local base, posBuff, negBuff = UnitAttackPower("player")
    local AttackPower = base + posBuff + negBuff
    
    -- 获取法术/远程属性
    local SpellPower = GetSpellBonusDamage(2) or 0 -- 神圣通常是基础
    for i=3, 7 do
         local s = GetSpellBonusDamage(i) or 0
         if s > SpellPower then SpellPower = s end
    end
    
    local baseR, posBuffR, negBuffR = UnitRangedAttackPower("player")
    local rangedAttackPower = baseR + posBuffR - negBuffR
    
    local rangedCrit = GetRangedCritChance() or 0
    local spellCritChance = GetSpellCritChance(2) or 0
    for i=3, 7 do
         local s = GetSpellCritChance(i) or 0
         if s > spellCritChance then spellCritChance = s end
    end
    
    local spellHasteRating = GetCombatRating(CR_HASTE_SPELL) or 0
    
    -- 常量（可被 TBC 覆盖）
    local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
    local ratingHasteRanged = ratings.Haste or 32.79
    local ratingSpellHit = ratings.SpellHit or 26.23
    local ratingMeleeHit = ratings.MeleeHit or 32.79
    
    local _, classEn = UnitClass("player")
    
    -- 天赋命中加成
    local primaryTree, talentName, prePoints = 1, L["NONE"], -1
    if ITank and ITank.Data and ITank.Data.IsMOP and ITank.Data.GetMoPSpecIndex then
        primaryTree = ITank.Data:GetMoPSpecIndex()
        talentName = L["UNKNOWN"]
    else
        for i = 1, 3 do
            local _, name, _, _, points = GetTalentTabInfo(i)
            points = tonumber(points) or 0
            if points > prePoints then
                prePoints, primaryTree, talentName = points, i, name or L["UNKNOWN"]
            end
        end
    end
    local talentPoints = self:GetTalentHitBonus(classEn, primaryTree)
    local meleeTalentPoints, spellTalentPoints = talentPoints, talentPoints
    if classEn == "SHAMAN" then
        meleeTalentPoints, spellTalentPoints = self:GetShamanTalentHitSplit()
    elseif classEn == "DEATHKNIGHT" then
        meleeTalentPoints, spellTalentPoints = self:GetDeathKnightTalentHitSplit(primaryTree)
    end
    

    
    -- 种族命中加成（德莱尼）
    local raceHit = self:GetRaceHitBonus()
    
    -- 套装加成（法师T1）
    local setHitBonus = self:GetMageT1HitBonus(classEn, itemSets)
    
    -- 命中加成字符串
    local hitBonusStr = ""
    -- if iTankDB and iTankDB.ShowHitDetails and (talentPoints > 0 or raceHit > 0 or setHitBonus > 0) then -- 原逻辑
    
    -- 新逻辑：根据三个独立的开关控制
    local showTalent = iTankDB and iTankDB.ShowTalentHit
    local showRace = iTankDB and iTankDB.ShowRaceHit
    local showSet = iTankDB and iTankDB.ShowSetHit
    
    if (showTalent and talentPoints > 0) or (showRace and raceHit > 0) or (showSet and setHitBonus > 0) then
         local parts = {}
         if showTalent and talentPoints > 0 then table.insert(parts, string.format(L["HIT_BONUS_TALENT"], talentPoints)) end
         if showRace and raceHit > 0 then table.insert(parts, string.format(L["HIT_BONUS_RACE"], raceHit)) end
         if showSet and setHitBonus > 0 then table.insert(parts, string.format(L["HIT_BONUS_SET"], setHitBonus)) end
         if #parts > 0 then
            hitBonusStr = string.format(L["HIT_BONUS_WRAPPER"], table.concat(parts, " "))
         end
    end

    local function BuildHitBonusString(talentBonus)
        local parts = {}
        if showTalent and talentBonus > 0 then table.insert(parts, string.format(L["HIT_BONUS_TALENT"], talentBonus)) end
        if showRace and raceHit > 0 then table.insert(parts, string.format(L["HIT_BONUS_RACE"], raceHit)) end
        if showSet and setHitBonus > 0 then table.insert(parts, string.format(L["HIT_BONUS_SET"], setHitBonus)) end
        if #parts > 0 then
            return string.format(L["HIT_BONUS_WRAPPER"], table.concat(parts, " "))
        end
        return ""
    end
    
    -- 颜色
    local C = self.Colors
    
    -- 职业逻辑
    -- 获取 HitCap（DK 随“命中属性选择”动态切换）
    local req = 8 -- default
    if classEn == "DEATHKNIGHT" then
        local mode = (iTankDB and iTankDB.DKHitMode) or 2
        req = (mode == 1) and 8 or 14
    else
        local capInfo = self.HitCaps[classEn]
        if type(capInfo) == "table" then
            req = capInfo[primaryTree] or 8
        elseif type(capInfo) == "number" then
            req = capInfo
        end
    end

    local auraHit = 0
    if ITank and ITank.Data then
        if ITank.Data.IsMOP then
            auraHit = 0
        elseif ITank.Data.GetDraeneiAuraHitBonus then
            auraHit = ITank.Data:GetDraeneiAuraHitBonus() or 0
        end
    end
    if classEn == "WARLOCK" or classEn == "MAGE" or classEn == "PRIEST" then
         local curHit = spellHitPercent + talentPoints + raceHit + setHitBonus + auraHit
         local hitColor = curHit < req and C.Red or C.Green
         
         local hitDiff = (curHit - req) * ratingSpellHit
         local hitDiffStr = ""
         if hitDiff > 0 then
             hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
         elseif hitDiff < 0 then
             hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
         end
         
         lines.line2 = SafeFormat(L["IDPS_CASTER_LINE2"], 
            Intellect, Spirit, hitColor, curHit, req, hitDiffStr, hitBonusStr)
            
         lines.line3 = SafeFormat(L["IDPS_CASTER_LINE3"],
            SpellPower, spellHasteRating / ratingHasteRanged, spellHasteRating, spellCritChance, GetCombatRating(CR_CRIT_SPELL) or 0)
            
    elseif classEn == "PALADIN" or classEn == "WARRIOR" or classEn == "DEATHKNIGHT" or classEn == "ROGUE" or classEn == "MONK" then
            local curHit = Hit + talentPoints + raceHit + setHitBonus + auraHit
            local currentHitBonusStr = hitBonusStr
         local hitRatingPerPercent = ratingMeleeHit
         if classEn == "DEATHKNIGHT" then
              local mode = (iTankDB and iTankDB.DKHitMode) or 2
              if mode == 1 then
                    curHit = Hit + meleeTalentPoints + setHitBonus + auraHit
                   hitRatingPerPercent = ratingMeleeHit
                    currentHitBonusStr = BuildHitBonusString(meleeTalentPoints)
              else
                    curHit = spellHitPercent + spellTalentPoints + setHitBonus + auraHit
                   hitRatingPerPercent = ratingSpellHit
                    currentHitBonusStr = BuildHitBonusString(spellTalentPoints)
              end
         end
         
         local hitColor = curHit < req and C.Orange or (curHit < req + 0.5 and C.Green or (curHit < req + 2 and C.Olive or C.DarkGreen))
         
         local hitDiff = (curHit - req) * hitRatingPerPercent
         local hitDiffStr = ""
         if hitDiff > 0 then
             hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
         elseif hitDiff < 0 then
             hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
         end
         
         local expCapSkill = (ITank and ITank.Data and ITank.Data.IsTBC) and 6.5 or 26
         local expPerSkill = ratings.Expertise or 8.1974
         local expRatingDiff = (Expertise - expCapSkill) * expPerSkill
         local expDiffStr = ""
         if expRatingDiff > 0 then
             expDiffStr = string.format(L["HIT_DIFF_POSITIVE"], expRatingDiff)
         elseif expRatingDiff < 0 then
             expDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], expRatingDiff)
         else
             expDiffStr = "0"
         end
         local expCurColor = (Expertise < expCapSkill) and C.Red or C.Green
         
         local expReq = 26
         local expColor = Expertise < expReq and C.Red or (Expertise == expReq and C.Green or (Expertise <= 30 and C.Olive or C.DarkGreen))
         
         lines.line2 = SafeFormat(L["IDPS_MELEE_LINE2"],
                Strength, Agility, hitColor, curHit, req, hitDiffStr, currentHitBonusStr or "", expCurColor, Expertise, tostring(expCapSkill), expDiffStr)
            
        if ITank and ITank.Data and ITank.Data.IsTBC then
           lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3_TBC"],
               AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0)
        else
           lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3"],
              AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0, ArP, GetCombatRating(CR_ARMOR_PENETRATION) or 0)
        end
            
    elseif classEn == "HUNTER" then
         -- 猎人使用远程命中 (CR_HIT_RANGED)
         -- rangedHitPercent 来自 GetCombatRatingBonus(CR_HIT_RANGED)，包含了装备、附魔（瞄准镜）提供的命中等级转换后的百分比
         -- 需额外叠加天赋、种族、套装加成
         local curHit = rangedHitPercent + talentPoints + raceHit + setHitBonus + auraHit
         
         local hitColor = curHit < req and C.Red or C.Green
         
         local hitRatingPerPercent = ratingMeleeHit -- 远程命中等级换算与近战相同 (32.79)
         local hitDiff = (curHit - req) * hitRatingPerPercent
         local hitDiffStr = ""
         if hitDiff > 0 then
             hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
         elseif hitDiff < 0 then
             hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
         end
         
         lines.line2 = SafeFormat(L["IDPS_HUNTER_LINE2"],
            Agility, Intellect, rangedAttackPower, hitColor, curHit, req, hitDiffStr, hitBonusStr)
            
        if ITank and ITank.Data and ITank.Data.IsTBC then
            lines.line3 = SafeFormat(L["IDPS_HUNTER_LINE3_TBC"],
               rangedCrit, GetCombatRating(CR_CRIT_RANGED) or 0, Haste, GetCombatRating(CR_HASTE_RANGED) or 0)
        else
            lines.line3 = SafeFormat(L["IDPS_HUNTER_LINE3"],
               rangedCrit, GetCombatRating(CR_CRIT_RANGED) or 0, Haste, GetCombatRating(CR_HASTE_RANGED) or 0, ArP, GetCombatRating(CR_ARMOR_PENETRATION) or 0)
        end
            
    elseif classEn == "SHAMAN" or classEn == "DRUID" then
         if classEn == "SHAMAN" and talentName == L["SPEC_ENHANCEMENT"] then
              local shMelee, shSpell = self:GetShamanTalentHitSplit()
              -- 增强萨满：检查近战命中，要求8%（双手专精+6%不参与物理命中）
              local curHit = Hit + shMelee + raceHit + auraHit
              local hitColor = curHit < req and C.Red or C.Green
              local hitRatingPerPercent = ratingMeleeHit
              local hitDiff = (curHit - req) * hitRatingPerPercent
              local hitDiffStr = ""
              if hitDiff > 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
              elseif hitDiff < 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
              end
              local expCapSkill = (ITank and ITank.Data and ITank.Data.IsTBC) and 6.5 or 26
              local expPerSkill = ratings.Expertise or 8.1974
              local expRatingDiff = (Expertise - expCapSkill) * expPerSkill
              local expDiffStr = ""
              if expRatingDiff > 0 then
                  expDiffStr = string.format(L["HIT_DIFF_POSITIVE"], expRatingDiff)
              elseif expRatingDiff < 0 then
                  expDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], expRatingDiff)
              else
                  expDiffStr = "0"
              end
              local expCurColor = (Expertise < expCapSkill) and C.Red or C.Green
              hitBonusStr = BuildHitBonusString(shMelee)
              lines.line2 = SafeFormat(L["IDPS_MELEE_LINE2"],
                 Strength, Agility, hitColor, curHit, req, hitDiffStr, hitBonusStr or "", expCurColor, Expertise, tostring(expCapSkill), expDiffStr)
              if ITank and ITank.Data and ITank.Data.IsTBC then
                  lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3_TBC"],
                     AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0)
              else
                  lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3"],
                     AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0, ArP, GetCombatRating(CR_ARMOR_PENETRATION) or 0)
              end

         elseif talentName == L["SPEC_FERAL_COMBAT"] then
              local curHit = Hit + talentPoints + raceHit + setHitBonus + auraHit
              local hitColor = curHit < req and C.Red or C.Green
              local hitRatingPerPercent = ratingMeleeHit
              
              local hitDiff = (curHit - req) * hitRatingPerPercent
              local hitDiffStr = ""
              if hitDiff > 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
              elseif hitDiff < 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
              end
              
              local expCapSkill = (ITank and ITank.Data and ITank.Data.IsTBC) and 6.5 or 26
              local expPerSkill = ratings.Expertise or 8.1974
              local expRatingDiff = (Expertise - expCapSkill) * expPerSkill
              local expDiffStr = ""
              if expRatingDiff > 0 then
                  expDiffStr = string.format(L["HIT_DIFF_POSITIVE"], expRatingDiff)
              elseif expRatingDiff < 0 then
                  expDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], expRatingDiff)
              else
                  expDiffStr = "0"
              end
              local expCurColor = (Expertise < expCapSkill) and C.Red or C.Green
              
              lines.line2 = SafeFormat(L["IDPS_MELEE_LINE2"],
                 Strength, Agility, hitColor, curHit, req, hitDiffStr, hitBonusStr or "", expCurColor, Expertise, tostring(expCapSkill), expDiffStr)
              
             if ITank and ITank.Data and ITank.Data.IsTBC then
                 lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3_TBC"],
                    AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0)
             else
                 lines.line3 = SafeFormat(L["IDPS_MELEE_LINE3"],
                    AttackPower, Crit, GetCombatRating(CR_CRIT_MELEE) or 0, Haste, GetCombatRating(CR_HASTE_MELEE) or 0, ArP, GetCombatRating(CR_ARMOR_PENETRATION) or 0)
             end
         else
              local shMelee, shSpell = self:GetShamanTalentHitSplit()
              local curHit = spellHitPercent + (classEn == "SHAMAN" and shSpell or talentPoints) + raceHit + setHitBonus + auraHit
              local hitColor = curHit < req and C.Red or C.Green
              
              local hitDiff = (curHit - req) * ratingSpellHit
              local hitDiffStr = ""
              if hitDiff > 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_POSITIVE"], hitDiff)
              elseif hitDiff < 0 then
                  hitDiffStr = string.format(L["HIT_DIFF_NEGATIVE"], hitDiff)
              end
              
              lines.line2 = SafeFormat(L["IDPS_CASTER_LINE2"],
                 Intellect, Spirit, hitColor, curHit, req, hitDiffStr, hitBonusStr)
                 
              lines.line3 = SafeFormat(L["IDPS_CASTER_LINE3"],
                 SpellPower, spellHasteRating / ratingHasteRanged, spellHasteRating, spellCritChance, GetCombatRating(CR_CRIT_SPELL) or 0)
         end
    else
         -- 后备
         lines.line2 = L["IDPS_UNKNOWN_CLASS"]
         lines.line3 = ""
    end
    
    return lines
end

-- 获取防御面板文本行
function ITank.Data:GetDefensePanelText()
    local texts = { col1 = "", col2 = "", col3 = "" }
    
    -- 获取集中数据
    local data = self:GetDefenseStats()
    if not data then return texts end
    
    -- 1. 组装第1列（属性）
    -- 圆桌差距颜色 (ct)
    local ctColor = "|cffff0000"..data.ct.."%|r" -- 默认红色
    if data.defneed > 0 then
        ctColor = "|cffff8000"..data.ct.."%|r" -- 如果易暴则橙色
    end
    if data.ct >= 0 then
        ctColor = "|cff00ff00"..data.ct.."%|r" -- 如果格挡达标则绿色
    end
    
    texts.col1 = string.format(L["DEFENSE_PANEL_TITLE"],
        data.miss, data.dodge, data.parry, data.block, data.total)
        
    -- 2. 组装第2列（技能）
    -- 防御文本
    local pdefStr = ""
    local defNeedStr = ""
    local _, classFilename, classId = UnitClass("player")
    local isBear = (classId == 11)
    
    if data.defneed <= 0 then
        pdefStr = "|cff00ff00"..data.pdef.."|r"
        defNeedStr = L["STATUS_OK"]
    else
        pdefStr = "|cffff0000"..data.pdef.."|r"
        local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
        local perSkill = ratings.DefensePerSkill or 4.9184
        defNeedStr = L["STATUS_MISSING"]..math.ceil(data.defneed * perSkill)..L["STATUS_LEVEL"]
    end
    
    if isBear then
         if data.defneed <= 0 then
             pdefStr = "|cff00ff00"..data.pdef.."|r"
         else
             pdefStr = "|cffff0000"..data.pdef.."|r"
         end
         defNeedStr = L["STATUS_NA"]
    end
    
    local defLine = string.format(L["DEFENSE_DEF_FMT"], pdefStr, defNeedStr)
    
    -- 命中文本
    local hitStr = ""
    local hitColor = ""
    local missingHitColor = ""
    
    if data.finalHitPercent >= data.hitReq then
        hitColor = "|cff00ff00" -- 绿色
        missingHitColor = "|cff00ff00"..L["STATUS_OK"]
    else
        hitColor = "|cffff0000" -- 红色
        missingHitColor = "|cffff0000"..data.missingHitLevel.."|r"
    end
    
    hitStr = string.format(L["DEFENSE_HIT_FMT"], hitColor, data.finalHitPercent, data.hitReq, missingHitColor)
    
    -- 精准文本
    local exptStr = ""
    local exptColor = ""
    local expCapSkill = (ITank and ITank.Data and ITank.Data.IsTBC) and 6.5 or 26
    local capStr = tostring(expCapSkill)
    if data.expt >= expCapSkill then
        exptColor = "|cff00ff00"
    else
        exptColor = "|cffff0000"
    end
    
    if data.expt >= expCapSkill then
        exptStr = string.format(L["DEFENSE_EXPT_FMT1"], exptColor, data.expt, capStr)
        local ratings = ITank and ITank.Data and ITank.Data.Ratings or {}
        local expPerSkill = ratings.Expertise or 8.1974
        local overflow = math.floor(math.max(0, data.expt - expCapSkill) * expPerSkill)
        if overflow > 0 then
            local overStr = "|cff00ff00" .. tostring(overflow) .. "|r"
            exptStr = exptStr .. "/" .. overStr
        end
    else
        local missStr = "|cffff0000" .. tostring(math.max(0, data.missExp or 0)) .. "|r"
        exptStr = string.format(L["DEFENSE_EXPT_FMT2"], exptColor, data.expt, capStr, missStr)
    end
    
    -- 护甲文本
    local armorStr = string.format(L["DEFENSE_ARMOR_FMT"], data.effectiveArmor)
    local drStr = string.format(L["DEFENSE_DR_FMT"], data.dr * 100)
    
    texts.col2 = string.format(L["DEFENSE_SKILL_TITLE"], defLine, hitStr, exptStr, armorStr, drStr)
    
    -- 3. 组装第3列（其他）
    local otherStr = ""
    
    -- 职业特定行
    if classId == 1 or classId == 2 then -- WARRIOR, PALADIN
         local sp = GetSpellBonusDamage(2) or 0
         for i = 3, 7 do
             local s = GetSpellBonusDamage(i) or 0
             if s > sp then sp = s end
         end
         otherStr = otherStr .. string.format(L["DEFENSE_BLOCK_VAL_FMT"], data.bv, sp)
    elseif classId == 6 then -- DK
         otherStr = otherStr .. string.format(L["DEFENSE_RESIL_FMT"], data.resil)
    elseif classId == 11 then -- DRUID
         if data.defneed > 0 then
             otherStr = otherStr .. string.format(L["DEFENSE_CRIT_DEF_FMT"], data.defneed, data.defneed * 2.36)
             otherStr = otherStr .. string.format(L["DEFENSE_CRIT_RESIL_FMT"], data.resilneed)
         else
             otherStr = otherStr .. L["DEFENSE_CRIT_DEF_OK"]
             otherStr = otherStr .. L["DEFENSE_CRIT_RESIL_OK"]
         end
    end
    
    -- TBC：免碾显示（战士/圣骑）
    if ITank and ITank.Data and ITank.Data.IsTBC and (classId == 1 or classId == 2) and data.uncrush ~= nil then
        local isOk = (data.uncrush >= 0)
        local color = isOk and "|cff00ff00" or "|cffff0000"
        local status = isOk and L["STATUS_UNCRUSH_OK"] or L["STATUS_UNCRUSH_NG"]
        local statusCol = color .. status .. "|r"
        local signValCol = color .. string.format("%+.2f%%", data.uncrush) .. "|r"
        otherStr = otherStr .. string.format(L["DEFENSE_UNCRUSH_LINE"], statusCol, signValCol)
    end
    
    otherStr = otherStr .. string.format(L["DEFENSE_AVOID_FMT"], data.avoidance)
    otherStr = otherStr .. string.format(L["DEFENSE_EHP_FMT"], data.hopeh)
    otherStr = otherStr .. string.format(L["ITANK_SCORE_FMT"], data.iTankScore)
    
    texts.col3 = L["DEFENSE_OTHER_TITLE"] .. otherStr
    
    return texts
end

-- ============================================================================
-- 6. 其他数据表
-- ============================================================================
-- 比如：宝石、附魔检查列表等
ITank.Data.Enchants = { --备用备查备清理
    -- [SlotID] = true/false (检查是否附魔) 需要处理 --备用备查备清理
} --备用备查备清理

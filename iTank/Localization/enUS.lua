local addonName, ns = ...
ns.L = ns.L or {}
local L = ns.L

-- Default English
L["SETTING_TITLE"] = "iTank Settings"
L["SETTING_SHOW_SETS"] = "Show equipped set info"
L["SETTING_SHOW_TALENT_HIT"] = "Show Talent Hit Info"
L["SETTING_SHOW_RACE_HIT"] = "Show Race Hit Info"
L["SETTING_SHOW_SET_HIT"] = "Show Set Hit Info"
L["SETTING_HIDE_IDPS_SKILL_LEVEL"] = "Hide skill level in iDPS (not implemented)"
L["SETTING_DK_HIT_MODE"] = "DK Hit Attribute Mode"
L["SETTING_DK_HIT_PHYSICAL"] = "8% Physical"
L["SETTING_DK_HIT_SPELL"] = "14% Spell"
L["SETTING_FONT_SIZE_TITLE"] = "Adjust Font Size"
L["SETTING_FONT_SIZE_FMT"] = "%d#"
L["SETTING_BG_ALPHA_TITLE"] = "Adjust Background Transparency"
L["SETTING_BG_ALPHA_FMT"] = "%.0f%%"
L["UNAVAILABLE_FOR_CLASS"] = " (Irrelevant to current class)"

-- Basic Info
L["ITANK_VERSION_FMT"] = "iTank V%s"
L["REALM_FMT"] = "Realm: %s"
L["PLAYER_FMT"] = "Name: %s"
L["CLASS_FMT"] = "Class: %s"
L["TALENT_FMT"] = "Talent: %s"
L["RACE_FMT"] = "Race: %s"
L["LEVEL_FMT"] = "Level: %d"
L["HP_FMT"] = "Health: %d"
L["POWER_FMT"] = "Power: %d"

-- iDPS Panel
L["IDPS_SCORE_FMT"] = "iDPS Score:%d%s"
L["IDPS_CASTER_LINE2"] = "Int:%d  Spi:%d  Hit:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_CASTER_LINE3"] = "SP:%d  Haste:%.2f%%/%d  Crit:%.2f%%/%d"
L["IDPS_MELEE_LINE2"] = "Str:%d  Agi:%d  Hit:%s%.2f%%|r/%.0f%%/%s%s  Exp:%s%.0f|r/%s/%s"
L["IDPS_MELEE_LINE3"] = "AP:%d  Crit:%.2f%%/%d  Haste:%.2f%%/%d  ArP:%.2f%%/%d"
L["IDPS_MELEE_LINE3_TBC"] = "AP:%d  Crit:%.2f%%/%d  Haste:%.2f%%/%d"
L["IDPS_HUNTER_LINE2"] = "Agi:%d  Int:%d  AP:%d  Hit:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_HUNTER_LINE3"] = "Crit:%.2f%%/%d  Haste:%.2f%%/%d  ArP:%.2f%%/%d"
L["IDPS_HUNTER_LINE3_TBC"] = "Crit:%.2f%%/%d  Haste:%.2f%%/%d"
L["IDPS_UNKNOWN_CLASS"] = "Unknown Class"

-- iDPS Precision Segment
L["IDPS_EXPERTISE_SEGMENT"] = "  Exp:%s%.0f|r/%s/%s"


-- MoP iDPS
L["IDPS_LINE1_MOP_MELEE"] = "iDPS Score:%d  Str:%d  Agi:%d  AP:%d%s"
L["IDPS_LINE1_MOP_CASTER"] = "iDPS Score:%d  Int:%d  Spi:%d  SP:%d%s"
L["IDPS_LINE2_MOP"] = "Hit:%s%.2f%%|r/%.1f%%/%s  Exp:%s%.2f%%|r/%d/%s"
L["IDPS_LINE2_MOP_CASTER"] = "Hit:%s%.2f%%|r/%.1f%%/%s"
L["IDPS_LINE3_MOP"] = "Haste:%.2f%%/%d  Crit:%.2f%%/%d  Mastery:%.2f%%/%d"

L["HIT_BONUS_TALENT"] = "Talent:%d%%"
L["HIT_BONUS_RACE"] = "Race:%d%%"
L["HIT_BONUS_SET"] = "Set:%d%%"
L["HIT_BONUS_WRAPPER"] = " (%s)"
L["HIT_DIFF_POSITIVE"] = "|cff00ff00%.0f|r"
L["HIT_DIFF_NEGATIVE"] = "|cffff0000%.0f|r"
L["UNAVAILABLE_IN_VERSION"] = " (Unavailable in this version)"

L["BUTTON_DEFENSE"] = "T"
L["BUTTON_DPS"] = "D"
L["BUTTON_SETTINGS"] = "S"
L["BUTTON_HELP"] = "?"
L["VERSION_SHORT"] = "V%s"

-- Button Tooltips
L["TOOLTIP_SETTINGS"] = "Open Settings"
L["TOOLTIP_DPS"] = "Show/Hide iDPS Panel"
L["TOOLTIP_DEFENSE"] = "Show/Hide Defense Panel"
L["TOOLTIP_HELP"] = "iTank Help"
L["ABOUTUS_TOOLTIP_BILIBILI"] = "Bilibili Home"
L["ABOUTUS_TOOLTIP_WCLBOX"] = "WCLBox Web"
L["ABOUTUS_TOOLTIP_DD"] = "NetEase DD Channel"
L["ABOUTUS_TOOLTIP_AFDIAN"] = "Afdian Home"
L["ABOUTUS_TOOLTIP_KDOCS"] = "About Us Doc"

L["MENU_INTERFACE"] = "Interface"
L["MENU_DATA"] = "Data"
L["SETTING_BG_COLOR"] = "Background Color"
L["SETTING_TEXT_COLOR"] = "Text Color"
L["MENU_ABOUT_HIT"] = "About Hit"
L["MENU_ABOUT_ADDON"] = "About Addon"
L["MENU_SPECIAL_THANKS"] = "Special Thanks"
L["MENU_ABOUT_US"] = "About Us"

L["INFO_SPECIAL_THANKS"] = [[
Thanks to the following UPs, addon authors, and players for their help:

露露緹婭
|cffffffffhttps://space.bilibili.com/455259|r

二哈吕老师
|cffffffffhttps://space.bilibili.com/2097768595|r

死木头
|cffffffffhttps://space.bilibili.com/17129246|r

老猫魔兽
|cffffffffhttps://space.bilibili.com/2128090786|r
]]

L["INFO_ADDON"] = [[
ahhz's iTank is a tank and DPS assistant plugin designed for WoW Classic, providing detailed defense/DPS attribute data to help players easily know how to adjust their gear and enchants.

iTank is a plugin version of the iTank WA. While retaining all the features and usage of the iTank WA, users have higher freedom to customize the combination of the basic info panel, iDPS panel, and defense info panel. Users can also choose the display format of some data according to their preferences.

Addon pack authors are welcome to contact us to create a customized Special Edition of iTank. Please contact the development team for details.

|cffffd100Features:|r
1. |cff00ff00Defense Panel|r: Displays four dimensions (Miss, Dodge, Parry, Block), round table analysis, crit immunity check, and Effective Health (EHP) estimation.
2. |cff00ff00iDPS Panel|r: Comprehensive scoring system based on relevant data read from the system, intuitively reflecting the character's output potential. It provides feedback to players in the form of scores on whether the result of gear adjustment is positive or negative.
]]

L["INFO_HIT"] = [[
|cffffd100Hit Rating:|r
The plugin automatically calculates and summarizes hit bonuses from gear, talents, races, and set bonuses.
- |cff00ccffTalent Hit|r: Automatically detects core hit talents (e.g., Mage's Precision, Shadow Priest's Shadow Focus).
- |cff00ccffRace Hit|r: Draenei racial bonus (+2%).
- |cff00ccffSet Hit|r: Set bonuses like Mage T1 set effect.

Hit percentage required for each class:
Percentage required from gear + Percentage increased by talent points
(For every 1% less in talents, 1% must be added from gear)
- |cffC79C6EWarrior|r: 5%+3% (Fury)
- |cffF58CBAPaladin|r: 8%
- |cffC41F3BDeath Knight|r: 14% (Spell Hit)
- |cffABD473Hunter|r: 5%+3%
- |cff0070DEShaman|r: 8% (Enhancement); 11%+3% (Elemental)
- |cffFFF569Rogue|r: 8%
- |cffFF7D0ADruid|r: 10% (Balance); 8% (Feral)
- |cff69CCF0Mage|r: 14%+3%
- |cff9482C9Warlock|r: 11/14%+3%
- |cffFFFFFFPriest|r: 11%+6%

Note: Physical classes default check 8%, caster classes check 14% (DK checks 14%).
]]
L["INFO_HIT_TBC"] = [[
|cffffd100About Hit (TBC)|r
- Physical hit: 9% (vs. level 73 bosses)
- Spell hit: 16% (vs. level 73 bosses)
- Expertise: 6.5 skill cap; 3.9 rating ≈ 1 skill
- Rating (Lv70): Melee/Ranged 15.77 per 1%; Spell 12.62 per 1%
- Raid aura: Draenei aura +1% hit (melee/ranged/spell)
- Notes: Talents/race/set/aura reduce gear hit requirements
]]

L["INFO_HIT_MOP"] = [[
|cffffd100About Hit (MoP)|r
- Physical hit: 7.5% (vs. level 93 bosses)
- Spell hit: 15% (vs. level 93 bosses)
- Expertise: 15 skill cap
- Level model: 90 vs 93 (+3). Ratings are handled automatically by the addon
- Notes: Talents/race/auras provide extra hit and lower gear requirements
]]

L["INFO_ABOUT_US"] = [[
iTank Studio Works

UI & Creative: ahhz
|cffffffffhttps://space.bilibili.com/294757892|r

Coding: Shuangyu(Spog), ahhz
|cffffffffhttps://space.bilibili.com/649961|r

Click the icons to get the corresponding link
]]

-- Help Window
L["HELP_TITLE"] = "iTank Help"
L["HELP_CONTENT"] = [[
Data Model:
- Hit: 8%; Expertise: 26; Defense level between 540–541;
- Shield classes' block value shows diminishing returns after 2400;
- iTank and iDPS scores indicate positive/negative direction, not exact numeric gains.
]]
L["HELP_CONTENT_TBC"] = [[
Data Model (TBC):
- Hit: 9% (physical); 16% for casters versus level 73 bosses
- Expertise: 6.5 skill cap; 3.9 rating per 1 expertise skill
- Defense: level 70 vs. boss level 73 used for DR and round-table math
- Block value: UI shows "BV/SP: <block>/<spell power>", no 2400 threshold check
- iTank and iDPS scores indicate direction, not exact numeric gains.
]]

-- Defense Panel
L["DEFENSE_PANEL_TITLE"] = "Stats Panel:\nMiss: %.2f%%\nDodge: %.2f%%\nParry: %.2f%%\nBlock: %.2f%%\nTotal: %.2f%%"
L["DEFENSE_SKILL_TITLE"] = "Skills Info:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_OTHER_TITLE"] = "Other Info:\n"

-- Basic Panel
L["OPTIONS_TITLE"] = "iTank Options"
L["BASIC_REALM"] = "Realm: %s"
L["BASIC_NAME"] = "Name: %s"
L["BASIC_CLASS"] = "Class: %s"
L["BASIC_TALENT"] = "Talent: %s"
L["SPEC_FMT"] = "Spec: %s"
L["BASIC_RACE"] = "Race: %s"
L["BASIC_LEVEL"] = "Level: %d"
L["BASIC_HP"] = "HP: %d"
L["BASIC_POWER"] = "Power: %d"

L["DEFENSE_DEF_FMT"] = "Def:%s/%s"
L["DEFENSE_HIT_FMT"] = "Hit:%s%.3f%%|r/%d%%/%s"
L["DEFENSE_EXPT_FMT1"] = "Exp:%s%.1f|r/%s"
L["DEFENSE_EXPT_FMT2"] = "Exp:%s%.1f|r/%s/%s"
L["DEFENSE_ARMOR_FMT"] = "Armor:%d"
L["DEFENSE_DR_FMT"] = "Armor DR:%.2f%%"

L["DEFENSE_BLOCK_VAL_FMT"] = "BV/SP:%.0f/%.0f\n"
L["DEFENSE_RESIL_FMT"] = "Resil Crit:%.2f%%\n"
L["DEFENSE_CRIT_DEF_FMT"] = "Crit Def:%.2f(%.1f)\n"
L["DEFENSE_CRIT_RESIL_FMT"] = "Crit Resil:%.2f\n"
L["DEFENSE_CRIT_DEF_OK"] = "Crit Def:OK\n"
L["DEFENSE_CRIT_RESIL_OK"] = "Crit Resil:OK\n"
L["DEFENSE_AVOID_FMT"] = "Phy Avoid:%.2f%%\n"
L["DEFENSE_EHP_FMT"] = "EHP:%.0f\n"
L["ITANK_SCORE_FMT"] = "iTank Score:%d"
L["DEFENSE_UNCRUSH_LINE"] = "Uncrush:%s/%s\n"
L["STATUS_UNCRUSH_OK"] = "OK"
L["STATUS_UNCRUSH_NG"] = "Not Met"

L["STATUS_OK"] = "OK|r"
L["STATUS_MISSING"] = "Miss:|cffff0000"
L["STATUS_LEVEL"] = "Lvl|r"
L["STATUS_NA"] = "----"
L["UNKNOWN"] = "Unknown"
L["NONE"] = "None"

-- Talent Names (English)
L["TALENT_PRECISION"] = "Precision"
L["TALENT_PRECISION_MAGE"] = "Precision"
L["TALENT_FOCUSED_AIM"] = "Focused Aim"
L["TALENT_SHADOW_FOCUS"] = "Shadow Focus"
L["TALENT_MISERY"] = "Misery"
L["TALENT_VIRULENCE"] = "Virulence"
L["TALENT_ELEMENTAL_PRECISION"] = "Elemental Precision"
L["TALENT_DUAL_WIELD_SPECIALIZATION"] = "Dual Wield Specialization"
L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"] = "Two-Handed Axes and Maces"
L["TALENT_SUPPRESSION"] = "Suppression"
L["TALENT_BALANCE_OF_POWER"] = "Balance of Power"
L["TALENT_SURVIVAL_OF_THE_FITTEST"] = "Survival of the Fittest"
L["TALENT_SUREFOOTED"] = "Surefooted"
L["TALENT_NATURES_GUIDANCE"] = "Nature's Guidance"
L["TALENT_ARCANE_FOCUS"] = "Arcane Focus"

-- Spec Names
L["SPEC_ENHANCEMENT"] = "Enhancement"
L["SPEC_BALANCE"] = "Balance"
L["SPEC_FERAL_COMBAT"] = "Feral Combat"
L["SPEC_FROST"] = "Frost"

-- Stats
-- MoP
L["DEFENSE_PANEL_TITLE_MOP"] = "Stats:\nMiss: %.2f%%\nDodge: %.2f%%\nParry: %.2f%%\nBlock: %.2f%%\nAvoid: %.2f%%"
L["DEFENSE_HIT_FMT_MOP"] = "Hit:%s%.3f%%|r/%.1f%%/%s"
L["DEFENSE_MASTERY_FMT"] = "Mastery:%.2f%%/%d"
L["DEFENSE_SKILL_TITLE_MOP"] = "Skills Info:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_AP_FMT"] = "AP:%d\n"
L["DEFENSE_SP_FMT"] = "SP:%d\n"
L["DEFENSE_CRITRATE_FMT"] = "Crit:%.2f%%\n"
L["INTELLECT"] = "Int" --备用备查备清理
L["SPIRIT"] = "Spi" --备用备查备清理
L["SPELL_POWER"] = "SP" --备用备查备清理
L["HIT"] = "Hit" --备用备查备清理
L["HASTE"] = "Haste" --备用备查备清理
L["CRIT"] = "Crit" --备用备查备清理
L["STRENGTH"] = "Str" --备用备查备清理
L["AGILITY"] = "Agi" --备用备查备清理
L["ATTACK_POWER"] = "AP" --备用备查备清理
L["ARP"] = "ArP" --备用备查备清理
L["EXPERTISE"] = "Exp" --备用备查备清理

L["HIT_TALENT_FMT"] = "Talent:%d%%" --备用备查备清理
L["HIT_RACE_FMT"] = "Race:%d%%" --备用备查备清理
L["HIT_SET_FMT"] = "Set:%d%%" --备用备查备清理

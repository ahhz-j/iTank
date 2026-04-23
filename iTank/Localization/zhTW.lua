local addonName, ns = ...
ns.L = ns.L or {}
local L = ns.L

if GetLocale() ~= "zhTW" then return end

-- Traditional Chinese
L["SETTING_TITLE"] = "iTank 設定"
L["SETTING_SHOW_SETS"] = "顯示已裝備套裝資訊"
L["SETTING_SHOW_TALENT_HIT"] = "顯示天賦命中資訊"
L["SETTING_SHOW_RACE_HIT"] = "顯示種族命中資訊"
L["SETTING_SHOW_SET_HIT"] = "顯示套裝命中資訊"
L["SETTING_HIDE_IDPS_SKILL_LEVEL"] = "iDPS不顯示技能等級數據（未實裝）"
L["SETTING_DK_HIT_MODE"] = "死騎命中屬性選擇"
L["SETTING_DK_HIT_PHYSICAL"] = "8% 物理"
L["SETTING_DK_HIT_SPELL"] = "14% 法術"
L["SETTING_FONT_SIZE_TITLE"] = "調整文字字號"
L["SETTING_FONT_SIZE_FMT"] = "%d#"
L["SETTING_BG_ALPHA_TITLE"] = "調整背景透明度"
L["SETTING_BG_ALPHA_FMT"] = "%.0f%%"
L["SETTING_BG_COLOR"] = "背景顏色"
L["SETTING_TEXT_COLOR"] = "文字顏色"
L["UNAVAILABLE_FOR_CLASS"] = "（與職業不相關）"

-- Basic Info
L["ITANK_VERSION_FMT"] = "iTank V%s"
L["REALM_FMT"] = "伺服器:%s"
L["PLAYER_FMT"] = "角色:%s"
L["CLASS_FMT"] = "職業:%s"
L["TALENT_FMT"] = "天賦:%s"
L["RACE_FMT"] = "種族:%s"
L["LEVEL_FMT"] = "等級:%d"
L["HP_FMT"] = "生命值:%d"
L["POWER_FMT"] = "能量值:%d"

-- iDPS Panel
L["IDPS_SCORE_FMT"] = "iDPS 評分:%d%s"
L["IDPS_CASTER_LINE2"] = "智力:%d  精神:%d  命中:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_CASTER_LINE3"] = "法傷:%d  加速:%.2f%%/%d  致命:%.2f%%/%d"
L["IDPS_MELEE_LINE2"] = "力量:%d  敏捷:%d  命中:%s%.2f%%|r/%.0f%%/%s%s  熟練:%s%.0f|r/%s/%s"
L["IDPS_MELEE_LINE3"] = "強度:%d  致命:%.2f%%/%d  加速:%.2f%%/%d  破甲:%.2f%%/%d"
L["IDPS_MELEE_LINE3_TBC"] = "強度:%d  致命:%.2f%%/%d  加速:%.2f%%/%d"
L["IDPS_HUNTER_LINE2"] = "敏捷:%d  智力:%d  強度:%d  命中:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_HUNTER_LINE3"] = "致命:%.2f%%/%d  加速:%.2f%%/%d  破甲:%.2f%%/%d"
L["IDPS_HUNTER_LINE3_TBC"] = "致命:%.2f%%/%d  加速:%.2f%%/%d"

-- iDPS Precision Segment
L["IDPS_EXPERTISE_SEGMENT"] = "  熟練:%s%.0f|r/%s/%s"

-- MoP iDPS
L["IDPS_LINE1_MOP_MELEE"] = "iDPS 評分:%d  力量:%d  敏捷:%d  攻強:%d%s"
L["IDPS_LINE1_MOP_CASTER"] = "iDPS 評分:%d  智力:%d  精神:%d  法傷:%d%s"
L["IDPS_LINE2_MOP"] = "命中:%s%.2f%%|r/%.1f%%/%s  熟練:%s%.2f%%|r/%d/%s"
L["IDPS_LINE2_MOP_CASTER"] = "命中:%s%.2f%%|r/%.1f%%/%s"
L["IDPS_LINE3_MOP"] = "加速:%.2f%%/%d  致命:%.2f%%/%d  精通:%.2f%%/%d"
L["IDPS_UNKNOWN_CLASS"] = "未適配職業"

L["HIT_BONUS_TALENT"] = "天賦:%d%%"
L["HIT_BONUS_RACE"] = "種族:%d%%"
L["HIT_BONUS_SET"] = "套裝:%d%%"
L["HIT_BONUS_WRAPPER"] = " (%s)"
L["HIT_DIFF_POSITIVE"] = "|cff00ff00%.0f|r"
L["HIT_DIFF_NEGATIVE"] = "|cffff0000%.0f|r"
L["UNAVAILABLE_IN_VERSION"] = "（當前版本不可用）"

L["BUTTON_DEFENSE"] = "T"
L["BUTTON_DPS"] = "D"
L["BUTTON_SETTINGS"] = "S"
L["BUTTON_HELP"] = "?"
L["VERSION_SHORT"] = "V%s"

-- Button Tooltips
L["TOOLTIP_SETTINGS"] = "打開設定選單"
L["TOOLTIP_DPS"] = "顯示/隱藏iDPS面板"
L["TOOLTIP_DEFENSE"] = "顯示/隱藏防禦屬性面板"
L["TOOLTIP_HELP"] = "iTank 說明"
L["ABOUTUS_TOOLTIP_BILIBILI"] = "B站主頁"
L["ABOUTUS_TOOLTIP_WCLBOX"] = "新手盒子網頁版"
L["ABOUTUS_TOOLTIP_DD"] = "網易DD聊天頻道"
L["ABOUTUS_TOOLTIP_AFDIAN"] = "愛發電主頁"
L["ABOUTUS_TOOLTIP_KDOCS"] = "關於我們文件"

L["MENU_INTERFACE"] = "介面選項"
L["MENU_DATA"] = "數據選項"
L["MENU_ABOUT_HIT"] = "關於命中"
L["MENU_ABOUT_ADDON"] = "關於插件"
L["MENU_SPECIAL_THANKS"] = "特別致謝"
L["MENU_ABOUT_US"] = "關於我們"

L["INFO_SPECIAL_THANKS"] = [[
感謝以下UP主、插件包作者、玩家提供的幫助:

露露緹婭
|cffffffffhttps://space.bilibili.com/455259|r

二哈吕老师
|cffffffffhttps://space.bilibili.com/2097768595|r

死木頭
|cffffffffhttps://space.bilibili.com/17129246|r

老貓魔獸
|cffffffffhttps://space.bilibili.com/2128090786|r
]]

L["INFO_ADDON"] = [[
ahhz's iTank 是一款專為魔獸世界懷舊服設計的坦克及輸出輔助數據表插件，為玩家提供詳細的防禦/輸出屬性數據以幫助玩家方便的知道應如何調整自己的裝備附魔。

iTank插件是iTank WA的插件化作品，在擁有iTank WA的全部功能和使用的情況下，用戶擁有更高的自由度，可以自定義基礎信息面板與iDPS面板、防禦信息面板的組合。並可按照自己的喜好選擇部分數據的顯示格式。

所有插件包作者均可聯繫我們製作「特別定制版」的 iTank 插件，詳情請聯繫開發團隊。

|cffffd100功能特色:|r
1. |cff00ff00防禦面板|r:顯示四維（未中、閃躲、招架、格擋）、圓桌數據分析、免爆等級檢查及有效生命值（EHP）估算。
2. |cff00ff00iDPS面板|r:基於從系統讀取的相關數據的綜合評分系統，直觀反映角色的輸出潛力。以評分方式向玩家提供裝備調整的結果是正向反饋還是負向反饋。
]]

L["INFO_HIT"] = [[
|cffffd100命中說明:|r
插件會自動計算並匯總來自裝備、天賦、種族、套裝與光環提供的命中加成。不同版本命中閾值各異，面板會按版本自動切換顯示與檢查。
- |cff00ccff天賦命中|r：自動檢測職業核心命中天賦
- |cff00ccff種族命中|r：如德萊尼種族/光環加成
- |cff00ccff套裝命中|r：如法師T1套裝等

各職業需要的命中百分比數據:
裝備需要的百分比+天賦點數增加的百分比
（天賦中每少點1%，裝備端則需補上1%）
- |cffC79C6E戰士|r:5%+3%（狂暴）
- |cffF58CBA騎士|r:8%
- |cffC41F3B死亡騎士|r:14%(法術命中)
- |cffABD473獵人|r:5%+3%
- |cff0070DE薩滿|r:8%（增強）；11%+3%（元素）
- |cffFFF569潛行者|r:8%
- |cffFF7D0A德魯伊|r:10%（鳥）；8%（貓）
- |cff69CCF0法師|r:14%+3%
- |cff9482C9術士|r:11/14%+3%
- |cffFFFFFF牧師|r:11%+6%

註:物理職業默認檢查8%，法系檢查14%（DK檢查14%）。
]]

L["INFO_HIT_TBC"] = [[
|cffffd100關於命中（TBC）|r
- 物理命中：9%（以73級Boss為參考）
- 法系命中：16%（以73級Boss為參考）
- 熟練上限：6.5 技能；3.9 熟練等級 = 1 技能
- 等級換算（Lv70）：近戰/遠程 15.77 等級 ≈ 1%；法術 12.62 等級 ≈ 1%
- 團隊光環：德萊尼光環 +1% 命中（近戰/遠程/法術）
- 說明：天賦/種族/套裝/光環為額外命中來源，降低裝備命中需求
]]

L["INFO_HIT_MOP"] = [[
|cffffd100關於命中（MoP）|r
- 物理命中：7.5%（以93級Boss為參考）
- 法系命中：15%（以93級Boss為參考）
- 熟練上限：15 技能
- 等級模型：90 對 93（+3級），插件按版本自動換算評級
- 說明：天賦/種族/光環等加成屬於額外命中來源，降低裝備命中需求
]]

L["INFO_ABOUT_US"] = [[
iTank Studio Works

UI&創意：ahhz
|cffffffffhttps://space.bilibili.com/294757892|r

編碼：霜語、ahhz
|cffffffffhttps://space.bilibili.com/649961|r

點擊圖標取得對應連結
]]

-- Help Window
L["HELP_TITLE"] = "iTank 說明"
L["HELP_CONTENT"] = [[
資料模型：
- 命中：8%；熟練26；防禦等級540–541之間；
- 持盾職業格擋值2400之後收益開始遞減；
- iTank 與 iDPS 評分僅表示「正向/反向」方向，不代表具體數值。
]]
L["HELP_CONTENT_TBC"] = [[
資料模型（TBC）：
- 命中：9%（物理）；法系16%（以73級Boss為參考）
- 熟練：6.5技能達標；3.9熟練等級=1技能
- 防禦：以70級玩家對73級Boss之等級差作為減傷與圓桌計算依據
- 格擋值：面板顯示「BV/SP：格擋值/法傷」，不再檢查2400閾值
- iTank 與 iDPS 評分僅表示「正向/反向」方向，不代表具體數值。
]]

-- Defense Panel
L["DEFENSE_PANEL_TITLE"] = "四維面板:\n未擊中:%.2f%%\n閃躲:%.2f%%\n招架:%.2f%%\n格擋:%.2f%%\n圓桌:%.2f%%"
L["DEFENSE_SKILL_TITLE"] = "技能資訊:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_OTHER_TITLE"] = "其他資訊:\n"

-- Basic Panel
L["OPTIONS_TITLE"] = "iTank 設定"
L["BASIC_REALM"] = "伺服器:%s"
L["BASIC_NAME"] = "角色:%s"
L["BASIC_CLASS"] = "職業:%s"
L["BASIC_TALENT"] = "天賦:%s"
L["SPEC_FMT"] = "專精:%s"
L["BASIC_RACE"] = "種族:%s"
L["BASIC_LEVEL"] = "等級:%d"
L["BASIC_HP"] = "生命值:%d"
L["BASIC_POWER"] = "能量值:%d"

L["DEFENSE_DEF_FMT"] = "防等:%s/%s"
L["DEFENSE_HIT_FMT"] = "命中:%s%.3f%%|r/%d%%/%s"
L["DEFENSE_EXPT_FMT1"] = "熟練:%s%.1f|r/%s"
L["DEFENSE_EXPT_FMT2"] = "熟練:%s%.1f|r/%s/%s"
L["DEFENSE_ARMOR_FMT"] = "護甲值:%d"
L["DEFENSE_DR_FMT"] = "護甲免傷:%.2f%%"

L["DEFENSE_BLOCK_VAL_FMT"] = "BV/SP：%.0f/%.0f\n"
L["DEFENSE_RESIL_FMT"] = "韌性免暴:%.2f%%\n"
L["DEFENSE_CRIT_DEF_FMT"] = "免暴防等:%.2f(%.1f)\n"
L["DEFENSE_CRIT_RESIL_FMT"] = "免暴韌性:%.2f\n"
L["DEFENSE_CRIT_DEF_OK"] = "免暴防等:已達標\n"
L["DEFENSE_CRIT_RESIL_OK"] = "免暴韌性:已達標\n"
L["DEFENSE_AVOID_FMT"] = "物理免傷:%.2f%%\n"
L["DEFENSE_EHP_FMT"] = "有效生命:%.0f\n"
L["ITANK_SCORE_FMT"] = "iTank評分:%d"
L["DEFENSE_UNCRUSH_LINE"] = "免碾:%s/%s\n"
L["STATUS_UNCRUSH_OK"] = "達標"
L["STATUS_UNCRUSH_NG"] = "未達標"

-- MoP 專用
L["DEFENSE_PANEL_TITLE_MOP"] = "四維面板:\n未擊中:%.2f%%\n閃躲:%.2f%%\n招架:%.2f%%\n格擋:%.2f%%\n免傷:%.2f%%"
L["DEFENSE_HIT_FMT_MOP"] = "命中:%s%.3f%%|r/%.1f%%/%s"
L["DEFENSE_MASTERY_FMT"] = "精通:%.2f%%/%d"
L["DEFENSE_SKILL_TITLE_MOP"] = "技能資訊:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_AP_FMT"] = "AP:%d\n"
L["DEFENSE_SP_FMT"] = "SP:%d\n"
L["DEFENSE_CRITRATE_FMT"] = "致命:%.2f%%\n"

L["STATUS_OK"] = "達標|r"
L["STATUS_MISSING"] = "缺:|cffff0000"
L["STATUS_LEVEL"] = "等級|r"
L["STATUS_NA"] = "----"
L["UNKNOWN"] = "未知"
L["NONE"] = "無"

-- Talent Names (Traditional Chinese)
L["TALENT_PRECISION"] = "精確"
L["TALENT_PRECISION_MAGE"] = "精準"
L["TALENT_FOCUSED_AIM"] = "專注瞄准"
L["TALENT_SHADOW_FOCUS"] = "暗影集中"
L["TALENT_MISERY"] = "悲慘"
L["TALENT_VIRULENCE"] = "惡毒"
L["TALENT_ELEMENTAL_PRECISION"] = "元素精準"
L["TALENT_DUAL_WIELD_SPECIALIZATION"] = "雙武器專精"
L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"] = "雙手武器專精"
L["TALENT_SUPPRESSION"] = "鎮壓"
L["TALENT_BALANCE_OF_POWER"] = "能量平衡"
L["TALENT_SURVIVAL_OF_THE_FITTEST"] = "獸群衛士"
L["TALENT_SUREFOOTED"] = "穩固"
L["TALENT_NATURES_GUIDANCE"] = "自然指引"
L["TALENT_ARCANE_FOCUS"] = "祕法集中"

-- Spec Names
L["SPEC_ENHANCEMENT"] = "增強"
L["SPEC_BALANCE"] = "平衡"
L["SPEC_FERAL_COMBAT"] = "野性戰鬥"
L["SPEC_FROST"] = "冰霜"


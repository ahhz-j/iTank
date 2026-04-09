local addonName, ns = ...
ns.L = ns.L or {}
local L = ns.L

if GetLocale() ~= "zhCN" then return end

-- Chinese
L["SETTING_TITLE"] = "iTank 设置"
L["SETTING_SHOW_SETS"] = "显示已装备套装信息"
L["SETTING_SHOW_TALENT_HIT"] = "显示天赋命中信息"
L["SETTING_SHOW_RACE_HIT"] = "显示种族命中信息"
L["SETTING_DK_HIT_MODE"] = "死骑命中属性选择"
L["SETTING_DK_HIT_PHYSICAL"] = "8% 物理"
L["SETTING_DK_HIT_SPELL"] = "14%法术"
L["SETTING_SHOW_SET_HIT"] = "显示套装命中信息"
L["SETTING_HIDE_IDPS_SKILL_LEVEL"] = "iDPS不显示技能等级数据（未实装）"
L["SETTING_DK_HIT_PHYSICAL"] = "8%物理"
L["SETTING_FONT_SIZE_TITLE"] = "调整文字字号"
L["SETTING_FONT_SIZE_FMT"] = "%d#"
L["SETTING_BG_ALPHA_TITLE"] = "调整背景透明度"
L["SETTING_BG_ALPHA_FMT"] = "%.0f%%"
L["SETTING_BG_COLOR"] = "背景颜色"
L["SETTING_TEXT_COLOR"] = "文字颜色"
L["UNAVAILABLE_FOR_CLASS"] = "（职业不相关）"

-- Basic Info
L["ITANK_VERSION_FMT"] = "iTank V%s"
L["REALM_FMT"] = "服务器:%s"
L["PLAYER_FMT"] = "角色:%s"
L["CLASS_FMT"] = "职业:%s"
L["TALENT_FMT"] = "天赋:%s"
L["SPEC_FMT"] = "专精:%s"
L["RACE_FMT"] = "种族:%s"
L["LEVEL_FMT"] = "等级:%d"
L["HP_FMT"] = "生命值:%d"
L["POWER_FMT"] = "能量值:%d"

-- iDPS Panel
L["IDPS_SCORE_FMT"] = "iDPS 评分:%d%s"
L["IDPS_CASTER_LINE2"] = "智力:%d  精神:%d  命中:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_CASTER_LINE3"] = "法伤:%d  急速:%.2f%%/%d  暴击:%.2f%%/%d"
L["IDPS_MELEE_LINE2"] = "力量:%d  敏捷:%d  命中:%s%.2f%%|r/%.0f%%/%s%s  精准:%s%.0f|r/%s/%s"
L["IDPS_MELEE_LINE3"] = "攻强:%d  暴击:%.2f%%/%d  急速:%.2f%%/%d  破甲:%.2f%%/%d"
L["IDPS_MELEE_LINE3_TBC"] = "攻强:%d  暴击:%.2f%%/%d  急速:%.2f%%/%d"
L["IDPS_HUNTER_LINE2"] = "敏捷:%d  智力:%d  攻强:%d  命中:%s%.2f%%|r/%.0f%%/%s%s"
L["IDPS_HUNTER_LINE3"] = "暴击:%.2f%%/%d  急速:%.2f%%/%d  破甲:%.2f%%/%d"
L["IDPS_HUNTER_LINE3_TBC"] = "暴击:%.2f%%/%d  急速:%.2f%%/%d"

-- iDPS Precision Segment
L["IDPS_EXPERTISE_SEGMENT"] = "  精准:%s%.0f|r/%s/%s"

-- MoP iDPS
L["IDPS_LINE1_MOP_MELEE"] = "iDPS 评分:%d  力量:%d  敏捷:%d  攻强:%d%s"
L["IDPS_LINE1_MOP_CASTER"] = "iDPS 评分:%d  智力:%d  精神:%d  法伤:%d%s"
L["IDPS_LINE2_MOP"] = "命中:%s%.2f%%|r/%.1f%%/%s  精准:%s%.2f%%|r/%d/%s"
L["IDPS_LINE2_MOP_CASTER"] = "命中:%s%.2f%%|r/%.1f%%/%s"
L["IDPS_LINE3_MOP"] = "急速:%.2f%%/%d  暴击:%.2f%%/%d  精通:%.2f%%/%d"
L["IDPS_UNKNOWN_CLASS"] = "未适配职业"

L["HIT_BONUS_TALENT"] = "天赋:%d%%"
L["HIT_BONUS_RACE"] = "种族:%d%%"
L["HIT_BONUS_SET"] = "套装:%d%%"
L["HIT_BONUS_WRAPPER"] = " (%s)"
L["HIT_DIFF_POSITIVE"] = "|cff00ff00%.0f|r"
L["HIT_DIFF_NEGATIVE"] = "|cffff0000%.0f|r"
L["UNAVAILABLE_IN_VERSION"] = "（当前版本不可用）"

L["BUTTON_DEFENSE"] = "T"
L["BUTTON_DPS"] = "D"
L["BUTTON_SETTINGS"] = "S"
L["BUTTON_HELP"] = "?"
L["VERSION_SHORT"] = "V%s"

-- Button Tooltips
L["TOOLTIP_SETTINGS"] = "打开设置菜单"
L["TOOLTIP_DPS"] = "显示/隐藏iDPS面板"
L["TOOLTIP_DEFENSE"] = "显示/隐藏防御数据面板"
L["TOOLTIP_HELP"] = "iTank 说明"
L["ABOUTUS_TOOLTIP_BILIBILI"] = "B站主页"
L["ABOUTUS_TOOLTIP_WCLBOX"] = "新手盒子网页版"
L["ABOUTUS_TOOLTIP_DD"] = "网易DD聊天频道"
L["ABOUTUS_TOOLTIP_AFDIAN"] = "爱发电主页"
L["ABOUTUS_TOOLTIP_KDOCS"] = "关于我们文档"

L["MENU_INTERFACE"] = "界面选项"
L["MENU_DATA"] = "数据选项"
L["MENU_ABOUT_HIT"] = "关于命中"
L["MENU_ABOUT_ADDON"] = "关于插件"
L["MENU_SPECIAL_THANKS"] = "特别致谢"
L["MENU_ABOUT_US"] = "关于我们"

L["INFO_SPECIAL_THANKS"] = [[


感谢以下UP主、插件包作者、玩家提供的帮助:

露露緹婭
|cffffffffhttps://space.bilibili.com/455259|r

二哈吕老师
|cffffffffhttps://space.bilibili.com/2097768595|r

死木头
|cffffffffhttps://space.bilibili.com/17129246|r

老猫魔兽
|cffffffffhttps://space.bilibili.com/2128090786|r
]]

L["INFO_ABOUT_US"] = [[
iTank Studio Works

UI&创意：ahhz
|cffffffffhttps://space.bilibili.com/294757892|r

编码：霜语、ahhz
|cffffffffhttps://space.bilibili.com/649961|r


点击图标获取对应链接
]]

L["INFO_ADDON"] = [[
ahhz's iTank 是一款专为魔兽世界怀旧服设计的坦克及输出辅助数据表插件，为玩家提供详细的防御/输出属性数据以帮助玩家方便的知道应如何调整自己的装备附魔。

iTank插件是iTank WA的插件化作品，在拥有iTank WA的全部功能和使用的情况下，用户拥有更高的自由度，可以自定义基础信息面板与iDPS面板、防御信息面板的组合。并可按照自己的喜好选择部分数据的显示格式。
所有插件包作者均可联系我们制作“特别定制版”的iTank插件，详情请联系开发团队。

|cffffd100功能特色:|r
1. |cff00ff00防御面板|r:显示四维（未中、闪避、招架、格挡）、圆桌数据分析、免爆等级检查及有效生命值（EHP）估算。
2. |cff00ff00iDPS面板|r:基于从系统读取的相关数据的综合评分系统，直观反映角色的输出潜力。以评分方式向玩家提供装备调整的结果是正向反馈还是负向反馈。
]]

L["INFO_HIT"] = [[
|cffffd100命中说明:|r
插件会自动计算并汇总来自装备、天赋、种族、套装与光环提供的命中加成。不同版本命中阈值不同，面板会按版本自动切换显示与检查。
- |cff00ccff天赋命中|r：自动检测职业核心命中天赋
- |cff00ccff种族命中|r：如德莱尼种族/光环加成
- |cff00ccff套装命中|r：如法师T1套装等

各职业需要的命中百分比数据:
装备需要的百分比+天赋点数增加的百分比
（天赋中每少点1%，装备端则需补上1%）
- |cffC79C6E战士|r:5%+3%（狂暴）
- |cffF58CBA骑士|r:8%
- |cffC41F3B死亡骑士|r:14%(法术命中)
- |cffABD473猎人|r:5%+3%
- |cff0070DE萨满|r:8%（增强）；11%+3%（元素）
- |cffFFF569潜行者|r:8%
- |cffFF7D0A德鲁伊|r:10%（鸟）；8%（猫）
- |cff69CCF0法师|r:14%+3%
- |cff9482C9术士|r:11/14%+3%
- |cffFFFFFF牧师|r:11%+6%

注:物理职业默认检查8%，法系检查14%（DK检查14%）。
]]

L["INFO_HIT_TBC"] = [[
|cffffd100关于命中（TBC）|r
- 物理命中：9%（以73级Boss为参考）
- 法系命中：16%（以73级Boss为参考）
- 精准上限：6.5 技能；3.9 精准等级 = 1 技能
- 等级换算（Lv70）：近战/远程 15.77 等级 ≈ 1%；法术 12.62 等级 ≈ 1%
- 团队光环：德莱尼光环 +1% 命中（近战/远程/法术）
- 说明：天赋/种族/套装/光环为额外命中来源，减少装备命中需求
]]

L["INFO_HIT_MOP"] = [[
|cffffd100关于命中（MoP）|r
- 物理命中：7.5%（以93级Boss为参考）
- 法系命中：15%（以93级Boss为参考）
- 精准上限：15 技能
- 等级模型：90 对 93（+3级），插件按版本自动换算评级
- 说明：天赋/种族/光环等加成为额外命中来源，减少装备命中需求
]]

-- Help Window
L["HELP_TITLE"] = "关于ahhz's iTank插件"
L["HELP_CONTENT"] = [[
iTank插件的数据建立模型：
-命中：8%；精准26；防御等级540-541之间；
-持盾职业格挡值2400以后收益开始衰减。
-iTank和iDPS评分仅表示“正向反馈”和“反向反馈”，不代表具体的装备调整真实数值结果。
]]

L["HELP_CONTENT_TBC"] = [[
iTank插件的数据建立模型（TBC）：
-命中：9%（物理）；法系16%（以73级Boss为参考）
-精准：6.5技能达标；3.9精准等级=1精准技能
-防御：以70级玩家对73级Boss的等级差作为减伤与圆桌计算依据
-格挡值：面板显示“BV/SP：格挡值/法伤”，不再检查2400阈值
-iTank和iDPS评分仅表示“正向反馈”和“反向反馈”，不代表具体的装备调整真实数值结果。
]]

-- Defense Panel
L["DEFENSE_PANEL_TITLE"] = "四维面板:\n未中:%.2f%%\n闪避:%.2f%%\n招架:%.2f%%\n格挡:%.2f%%\n圆桌:%.2f%%"
L["DEFENSE_SKILL_TITLE"] = "技能信息:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_OTHER_TITLE"] = "其他信息:\n"

-- Basic Panel
L["OPTIONS_TITLE"] = "iTank 设置"
L["BASIC_REALM"] = "服务器:%s"
L["BASIC_NAME"] = "角色:%s"
L["BASIC_CLASS"] = "职业:%s"
L["BASIC_TALENT"] = "天赋:%s"
L["BASIC_RACE"] = "种族:%s"
L["BASIC_LEVEL"] = "等级:%d"
L["BASIC_HP"] = "生命值:%d"
L["BASIC_POWER"] = "能量值:%d"

L["DEFENSE_DEF_FMT"] = "防等:%s/%s"
L["DEFENSE_HIT_FMT"] = "命中:%s%.3f%%|r/%d%%/%s"
L["DEFENSE_EXPT_FMT1"] = "精准:%s%.1f|r/%s"
L["DEFENSE_EXPT_FMT2"] = "精准:%s%.1f|r/%s/%s"
L["DEFENSE_ARMOR_FMT"] = "护甲值:%d"
L["DEFENSE_DR_FMT"] = "护甲免伤:%.2f%%"

L["DEFENSE_BLOCK_VAL_FMT"] = "BV/SP：%.0f/%.0f\n"
L["DEFENSE_RESIL_FMT"] = "韧性免爆:%.2f%%\n"
L["DEFENSE_CRIT_DEF_FMT"] = "免爆防等:%.2f(%.1f)\n"
L["DEFENSE_CRIT_RESIL_FMT"] = "免爆韧性:%.2f\n"
L["DEFENSE_CRIT_DEF_OK"] = "免爆防等:已达标\n"
L["DEFENSE_CRIT_RESIL_OK"] = "免爆韧性:已达标\n"
L["DEFENSE_AVOID_FMT"] = "物理免伤:%.2f%%\n"
L["DEFENSE_EHP_FMT"] = "有效生命:%.0f\n"
L["ITANK_SCORE_FMT"] = "iTank评分:%d"
L["DEFENSE_UNCRUSH_LINE"] = "免碾:%s/%s\n"
L["STATUS_UNCRUSH_OK"] = "达标"
L["STATUS_UNCRUSH_NG"] = "未达标"

-- MoP 专用
L["DEFENSE_PANEL_TITLE_MOP"] = "四维面板:\n未中:%.2f%%\n闪避:%.2f%%\n招架:%.2f%%\n格挡:%.2f%%\n免伤:%.2f%%"
L["DEFENSE_HIT_FMT_MOP"] = "命中:%s%.3f%%|r/%.1f%%/%s"
L["DEFENSE_MASTERY_FMT"] = "精通:%.2f%%/%d"
L["DEFENSE_SKILL_TITLE_MOP"] = "技能信息:\n%s\n%s\n%s\n%s\n%s"
L["DEFENSE_AP_FMT"] = "AP:%d\n"
L["DEFENSE_SP_FMT"] = "SP:%d\n"
L["DEFENSE_CRITRATE_FMT"] = "暴击:%.2f%%\n"

L["STATUS_OK"] = "达标|r"
L["STATUS_MISSING"] = "缺:|cffff0000"
L["STATUS_LEVEL"] = "等级|r"
L["STATUS_NA"] = "----"
L["UNKNOWN"] = "未知"
L["NONE"] = "无"

-- Talent Names (Chinese)
L["TALENT_PRECISION"] = "精确"
L["TALENT_PRECISION_MAGE"] = "精准"
L["TALENT_FOCUSED_AIM"] = "专注瞄准"
L["TALENT_SHADOW_FOCUS"] = "暗影集中"
L["TALENT_MISERY"] = "悲惨"
L["TALENT_VIRULENCE"] = "恶毒"
L["TALENT_ELEMENTAL_PRECISION"] = "元素精准"
L["TALENT_DUAL_WIELD_SPECIALIZATION"] = "双武器专精"
L["TALENT_TWO_HANDED_AXE_AND_MACE_SPECIALIZATION"] = "双手武器专精"
L["TALENT_SUPPRESSION"] = "镇压"
L["TALENT_BALANCE_OF_POWER"] = "能量平衡"
L["TALENT_SURVIVAL_OF_THE_FITTEST"] = "兽群卫士"
L["TALENT_SUREFOOTED"] = "稳固"
L["TALENT_NATURES_GUIDANCE"] = "自然指引"
L["TALENT_ARCANE_FOCUS"] = "奥术集中"

-- Spec Names
L["SPEC_ENHANCEMENT"] = "增强"
L["SPEC_BALANCE"] = "平衡"
L["SPEC_FERAL_COMBAT"] = "野性战斗"
L["SPEC_FROST"] = "冰霜"

-- Stats
L["INTELLECT"] = "智力" --备用备查备清理
L["SPIRIT"] = "精神" --备用备查备清理
L["SPELL_POWER"] = "法伤" --备用备查备清理
L["HIT"] = "命中" --备用备查备清理
L["HASTE"] = "急速" --备用备查备清理
L["CRIT"] = "暴击" --备用备查备清理
L["STRENGTH"] = "力量" --备用备查备清理
L["AGILITY"] = "敏捷" --备用备查备清理
L["ATTACK_POWER"] = "攻强" --备用备查备清理
L["ARP"] = "破甲" --备用备查备清理
L["EXPERTISE"] = "精准" --备用备查备清理

L["HIT_TALENT_FMT"] = "天赋:%d%%" --备用备查备清理
L["HIT_RACE_FMT"] = "种族:%d%%" --备用备查备清理
L["HIT_SET_FMT"] = "套装:%d%%" --备用备查备清理

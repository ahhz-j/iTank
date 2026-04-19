# iTank 插件

## 概述
- 版本：1.0.1
- 说明：“iTank-坦克宝典”是从WeakAuras同名项目转化的，为魔兽世界坦克与输出玩家设计的属性数据统计类独立插件。插件提供基础信息、iDPS数据与防御数据的分区展示，为玩家进行装备配置提供了直观方便的数据参考。设置面板通过选项可对界面进行调整以符合玩家的个人需要。得益于插件包作者的集成，iTank已经在事实上是世界上分发数量最大，下载次数最多，装机量最广的坦克/输出数据类插件。

## 安装与启动
- 将目录 `iTank` 复制到 `Interface\AddOns\`。
- 在角色选择界面启用 iTank。
- 游戏内输入 `/itank` 打开或关闭设置窗口。
- 打开角色面板（默认 `C`），主界面显示在角色面板下方。

## 主界面
- 面板结构（从上到下）：
  - 基础信息（Basic）
  - iDPS 面板（DPS）
  - 防御信息（Defense）
- 按钮（位于基础信息区域）：
  - “D”：显示/隐藏 iDPS 面板
  - “T”：显示/隐藏 防御面板
  - “S”：打开设置
  - “？”：打开帮助
- 显示逻辑：
  - 面板高度依据当前子面板高度动态计算。

## 设置
- 界面选项（滑块均为“标题在前、滑块在后”且左对齐）：
  - 文字字号：10–16，步长 1
  - 背景透明度：0–50%，步长 10%
  - 基础信息面板高度：30–60，步长 2
  - iDPS 面板高度：30–60，步长 2
  - 防御面板高度：50–100，步长 2
- 命中选项（数据面板）：
  - 显示天赋命中信息
  - 显示种族命中信息
  - 显示套装命中信息
  - 死亡骑士命中属性：8% 物理 / 14% 法术（二选一，非死亡骑士自动置灰）
- 常规设置写入 SavedVariables：`iTankDB`。

## 定制版持久化
- SE 定制信息支持持久化写入 `iTankSEDB`（WTF 文件），用于覆盖默认的图标与多语言文案。
- 默认模板仍保留在 `Data/iTank_SE.lua`，当 `iTankSEDB` 未配置某字段时自动回退。
- 适用场景：给不同接收用户分发不同的 WTF 定制文件，即可保持同一插件包下显示不同 SE 版本信息。
- `iTankSEDB` 结构示例：
  - `iconPath = "Interface\\AddOns\\iTank\\Media\\your_logo.jpg"`
  - `text.zhCN.title / text.zhCN.body`
  - `text.zhTW.title / text.zhTW.body`
  - `text.enUS.title / text.enUS.body`

## 关于我们面板
- 文本说明下方显示 5 个图标（32×32，居中）：bilibili、wclbox、dd、afdian、kdocs。
- 悬停显示本地化提示文字。
- 点击在聊天输入框写入相应链接并选中：
  - Bilibili：https://space.bilibili.com/294757892
  - WCLBox：https://www.wclbox.com/games/1/StringItem/4399
  - NetEase DD：https://dd.163.com/room/311796
  - 爱发电：https://afdian.com/a/ahhz147344
  - 金山文档：https://www.kdocs.cn/l/crBKZnyimQbH

## 帮助
- 帮助面板仅显示“数据模型”摘要：
  - 命中：8%；精准（熟练）26；防御等级 540–541
  - 格挡值 2400 以后收益递减（持盾职业）
  - iTank 与 iDPS 评分表示方向性，不代表具体数值增益

## 本地化
- 提供 zhCN、zhTW、enUS 三种语言包。
- 所有新选项与提示文本已同步三语本地化。

## 文件结构
- `iTank.toc`：主插件元数据与加载顺序
- `dd_author.toc`：附带的额外 toc/分发标记文件
- `iTank.lua`：主入口逻辑（事件、斜杠命令与公共运行时）
- `Data/`：数据与模板资源（`Sets.lua`、`data.lua`、`data_tbc.lua`、`data_mop.lua`、`iTank_SE.lua`）
- `UI/`：界面模块（`MainFrame.lua`、`OptionsFrame.lua`、`HelpFrame.lua`、`Util.lua`）
- `Localization/`：多语言资源（`zhCN.lua`、`zhTW.lua`、`enUS.lua`）
- `Media/`：图标与素材资源
- `Docs/`：附加文档（`Changelog.md`、`readme.en.md`、`readme.zhTW.md`、`MediaUsage.md`）
- `readme.md`：中文使用说明

## 版本记录
- 详见 `Docs/Changelog.md`。

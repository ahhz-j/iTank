# iTank 插件

## 概述
- 版本：1.0.2
- 說明：「iTank-坦克寶典」是從 WeakAuras 同名專案轉化而來，為魔獸世界坦克與輸出玩家設計的屬性數據統計類獨立插件。插件提供基礎資訊、iDPS 數據與防禦數據的分區展示，為玩家進行裝備配置提供直觀且方便的數據參考。設定面板可透過選項調整介面，以符合玩家的個人需要。得益於插件包作者的整合，iTank 已經在事實上成為世界上分發數量最大、下載次數最多、裝機量最廣的坦克／輸出數據類插件。

## 安裝與啟動
- 將目錄 iTank 複製到 Interface\AddOns\。
- 在角色選擇介面啟用 iTank。
- 遊戲內輸入 /itank 開啟或關閉設定視窗。
- 開啟角色面板（預設 C），主介面顯示在角色面板下方。

## 主介面
- 面板結構（從上到下）：
  - 基礎資訊（Basic）
  - iDPS 面板（DPS）
  - 防禦資訊（Defense）
- 按鈕（位於基礎資訊區域）：
  - 「D」：顯示/隱藏 iDPS 面板
  - 「T」：顯示/隱藏 防禦面板
  - 「S」：開啟設定
  - 「？」：開啟幫助
- 顯示邏輯：
  - 面板高度依據當前子面板高度動態計算。

## 設定
- 介面選項（滑桿均為「標題在前、滑桿在後」且左對齊）：
  - 文字字號：10–16，步長 1
  - 背景透明度：0–50%，步長 10%
  - 基礎資訊面板高度：30–60，步長 2
  - iDPS 面板高度：30–60，步長 2
  - 防禦面板高度：50–100，步長 2
- 命中選項（數據面板）：
  - 顯示天賦命中資訊
  - 顯示種族命中資訊
  - 顯示套裝命中資訊
  - 死亡騎士命中屬性：8% 物理 / 14% 法術（二選一，非死亡騎士自動置灰）
- 常規設定寫入 SavedVariables：iTankDB。

## 定製版持久化
- SE 定製資訊支援持久化寫入 iTankSEDB（WTF 檔案），用於覆蓋預設的圖標與多語言文案。
- 預設模板仍保留在 Data/iTank_SE.lua，當 iTankSEDB 未設定某欄位時自動回退。
- 適用場景：給不同接收使用者分發不同的 WTF 定製檔案，即可保持同一插件包下顯示不同的 SE 版本資訊。
- iTankSEDB 結構示例：
  - iconPath = "Interface\\AddOns\\iTank\\Media\\your_logo.jpg"
  - text.zhCN.title / text.zhCN.body
  - text.zhTW.title / text.zhTW.body
  - text.enUS.title / text.enUS.body

## 關於我們面板
- 文字說明下方顯示 5 個圖標（32×32，居中）：bilibili、wclbox、dd、afdian、kdocs。
- 懸停顯示本地化提示文字。
- 點擊在聊天輸入框寫入相應連結並選中：
  - Bilibili：https://space.bilibili.com/294757892
  - WCLBox：https://www.wclbox.com/games/1/StringItem/4399
  - NetEase DD：https://dd.163.com/room/311796
  - 愛發電：https://afdian.com/a/ahhz147344
  - 金山文檔：https://www.kdocs.cn/l/crBKZnyimQbH

## 幫助
- 幫助面板僅顯示「數據模型」摘要：
  - 命中：8%；精準（熟練）26；防禦等級 540–541
  - 格擋值 2400 以後收益遞減（持盾職業）
  - iTank 與 iDPS 評分表示方向性，不代表具體數值增益

## 本地化
- 提供 zhCN、zhTW、enUS 三種語言包。
- 所有新選項與提示文字已同步三語本地化。

## 檔案結構
- iTank.toc：主插件元數據與載入順序
- dd_author.toc：附帶的額外 toc／分發標記檔案
- iTank.lua：主入口邏輯（事件、斜槓命令與公共運行時）
- Data/：數據與模板資源（Sets.lua、data.lua、data_tbc.lua、data_mop.lua、iTank_SE.lua）
- UI/：介面模組（MainFrame.lua、OptionsFrame.lua、HelpFrame.lua、Util.lua）
- Localization/：多語言資源（zhCN.lua、zhTW.lua、enUS.lua）
- Media/：圖標與素材資源
- Docs/：附加文件（Changelog.md、readme.en.md、readme.zhTW.md、MediaUsage.md）
- readme.md：中文使用說明

## 版本記錄
- 詳見 Docs/Changelog.md。
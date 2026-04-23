# iTank Addon

## Overview
- Version: 1.0.2
- Description: "iTank - Tank Codex" was converted from the WeakAuras project of the same name. It is a standalone attribute-statistics addon designed for World of Warcraft tank and DPS players. The addon provides partitioned displays for basic information, iDPS data, and defense data, offering intuitive and convenient reference data for gear setup decisions. The settings panel allows players to adjust the interface through options to better fit personal preferences. Thanks to the integration work of the addon package author, iTank has effectively become the most widely distributed, most downloaded, and most broadly installed tank/DPS data addon in the world.

## Installation and Startup
- Copy the iTank directory to Interface\AddOns\.
- Enable iTank on the character selection screen.
- In game, type /itank to open or close the settings window.
- Open the character panel (default C); the main interface is displayed below the character panel.

## Main Interface
- Panel structure (from top to bottom):
  - Basic Information (Basic)
  - iDPS Panel (DPS)
  - Defense Information (Defense)
- Buttons (located in the basic information area):
  - "D": Show/Hide iDPS panel
  - "T": Show/Hide defense panel
  - "S": Open settings
  - "?": Open help
- Display logic:
  - Panel height is dynamically calculated based on the current sub-panel height.

## Settings
- Interface options (sliders are "title first, slider after" and left-aligned):
  - Font size: 10–16, step 1
  - Background transparency: 0–50%, step 10%
  - Basic information panel height: 30–60, step 2
  - iDPS panel height: 30–60, step 2
  - Defense panel height: 50–100, step 2
- Hit options (data panel):
  - Display talent hit information
  - Display racial hit information
  - Display set hit information
  - Death Knight hit attribute: 8% physical / 14% spell (choose one, automatically grayed out for non-Death Knights)
- General settings are written to SavedVariables: iTankDB.

## Customized Persistence
- SE customization data supports persistent storage in iTankSEDB (the WTF file) and can override the default icon and multilingual text.
- The default template remains in Data/iTank_SE.lua, and fields missing from iTankSEDB automatically fall back to the template values.
- Use case: distribute different WTF customization files to different recipients while keeping the same addon package and showing different SE version information.
- iTankSEDB structure example:
  - iconPath = "Interface\\AddOns\\iTank\\Media\\your_logo.jpg"
  - text.zhCN.title / text.zhCN.body
  - text.zhTW.title / text.zhTW.body
  - text.enUS.title / text.enUS.body

## About Us Panel
- Below the text description, display 5 icons (32×32, centered): bilibili, wclbox, dd, afdian, kdocs.
- Hover to display localized tooltip text.
- Click to write the corresponding link in the chat input box and select it:
  - Bilibili: https://space.bilibili.com/294757892
  - WCLBox: https://www.wclbox.com/games/1/StringItem/4399
  - NetEase DD: https://dd.163.com/room/311796
  - Afdian: https://afdian.com/a/ahhz147344
  - Kdocs: https://www.kdocs.cn/l/crBKZnyimQbH

## Help
- The help panel only displays a "Data Model" summary:
  - Hit: 8%; Precision (Proficiency) 26; Defense Rating 540–541
  - Block value diminishing returns after 2400 (shield-wielding classes)
  - iTank and iDPS ratings indicate directionality, not specific numerical gains

## Localization
- Provides zhCN, zhTW, enUS three language packs.
- All new options and tooltip texts have been synchronized in three languages.

## File Structure
- iTank.toc: Main addon metadata and load order
- dd_author.toc: Additional toc / distribution marker file
- iTank.lua: Main entry logic (events, slash commands, and shared runtime)
- Data/: Data and template resources (Sets.lua, data.lua, data_tbc.lua, data_mop.lua, iTank_SE.lua)
- UI/: UI modules (MainFrame.lua, OptionsFrame.lua, HelpFrame.lua, Util.lua)
- Localization/: Multilingual resources (zhCN.lua, zhTW.lua, enUS.lua)
- Media/: Icons and media assets
- Docs/: Supplementary documents (Changelog.md, readme.en.md, readme.zhTW.md, MediaUsage.md)
- readme.md: Chinese usage guide

## Version History
- See Docs/Changelog.md for details.

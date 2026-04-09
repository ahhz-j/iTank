# iTank Addon

## Overview
- Version: 0.9.8
- Description: iTank is an independent addon oriented towards tank and DPS attribute display, providing partitioned display of basic information, iDPS and defense data, as well as configurable interface options.

## Installation and Startup
- Copy the `iTank` directory to `Interface\AddOns\`.
- Enable iTank in the character selection interface.
- In-game, type `/itank` to open or close the settings window.
- Open the character panel (default `C`), the main interface is displayed below the character panel.

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
- All settings are written to SavedVariables: `iTankDB`.

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
- `iTank.toc`: Addon metadata
- `iTank.lua`: Main logic (events, slash commands, main interface and settings interface)
- `data.lua`: Data and calculation logic
- `Localization/`: Multilingual resources
- `Media/`: Icons and materials
- `Changelog.md`: Version update log
- `readme.md`: Usage instructions

## Version History
- See `Changelog.md` for details.

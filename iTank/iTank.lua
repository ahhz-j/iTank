-- ============================================================================
-- 入口 / 引导
-- 类别：引导/全局
-- 职责：命名空间初始化、SavedVariables 守卫、SE 工具函数、角色面板挂钩、斜杠命令、事件派发
-- UI 模块已拆分至 UI/ 子目录，通过 ITank 全局命名空间互联。
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}
ns = ns or {}
ns.ITank = ITank

local ITANK_VERSION = "1.0.0"
ITank.VERSION = ITANK_VERSION

-- 主表：存储配置
iTankDB = iTankDB or {}
iTankSEDB = iTankSEDB or {}

local function EnsureSEDBDefaults()
    iTankSEDB = iTankSEDB or {}
    if not (ITank and type(ITank.SE_INFO) == "table") then
        return
    end

    if iTankSEDB.iconPath == nil and type(ITank.SE_INFO.iconPath) == "string" then
        iTankSEDB.iconPath = ITank.SE_INFO.iconPath
    end

    if type(iTankSEDB.text) ~= "table" then
        iTankSEDB.text = {}
    end

    if type(ITank.SE_INFO.text) == "table" then
        for locale, src in pairs(ITank.SE_INFO.text) do
            if type(src) == "table" then
                local dst = iTankSEDB.text[locale]
                if type(dst) ~= "table" then
                    dst = {}
                    iTankSEDB.text[locale] = dst
                end
                if dst.title == nil and src.title ~= nil then
                    dst.title = src.title
                end
                if dst.body == nil and src.body ~= nil then
                    dst.body = src.body
                end
            end
        end
    end
end

local function GetSEInfo()
    local defaults = ITank and ITank.SE_INFO
    local db = type(iTankSEDB) == "table" and iTankSEDB or nil

    if not db then
        return defaults
    end

    local out = {}
    if type(db.iconPath) == "string" and db.iconPath ~= "" then
        out.iconPath = db.iconPath
    elseif defaults and type(defaults.iconPath) == "string" then
        out.iconPath = defaults.iconPath
    end

    local defaultText = (defaults and type(defaults.text) == "table") and defaults.text or nil
    local dbText = type(db.text) == "table" and db.text or nil
    local localeSet = { enUS = true }

    if defaultText then
        for locale in pairs(defaultText) do
            localeSet[locale] = true
        end
    end
    if dbText then
        for locale in pairs(dbText) do
            localeSet[locale] = true
        end
    end

    local textOut
    for locale in pairs(localeSet) do
        local srcDb = dbText and dbText[locale]
        local srcDefault = defaultText and defaultText[locale]
        local title = (type(srcDb) == "table" and srcDb.title) or (type(srcDefault) == "table" and srcDefault.title)
        local body = (type(srcDb) == "table" and srcDb.body) or (type(srcDefault) == "table" and srcDefault.body)

        if title ~= nil or body ~= nil then
            textOut = textOut or {}
            textOut[locale] = {
                title = title,
                body = body,
            }
        end
    end

    if textOut then
        out.text = textOut
    end

    if out.iconPath or out.text then
        return out
    end

    return defaults
end

-- 发布到全局命名空间，供 UI/MainFrame.lua 使用
ITank.GetSEInfo = GetSEInfo

-- 绑定角色面板显示/隐藏
local function HookCharacterFrame()
    if ITank.CharacterHooked then return end

    local function EnsureMainFrameParent()
        if not CharacterFrame then return end
        local main = ITank.MainFrame or ITank.CreateMainFrame()
        if main:GetParent() ~= CharacterFrame then
            main:SetParent(CharacterFrame)
        end
        if main.UpdatePosition then
            main:UpdatePosition()
        else
            main:ClearAllPoints()
            local ox = iTankDB.MainOffsetX or 13
            local oy = iTankDB.MainOffsetY or 40
            main:SetPoint("TOPLEFT", CharacterFrame, "BOTTOMLEFT", ox, oy)
        end
        main:SetFrameStrata("BACKGROUND")
        main:EnableMouse(false)
        main:EnableKeyboard(false)
        main:Show()
    end

    if CharacterFrame then
        EnsureMainFrameParent()
        -- 如果 CharacterFrame 已经显示，确保我们的框架也显示
        if CharacterFrame:IsVisible() then
            if ITank.MainFrame then ITank.MainFrame:Show() end
        end
    else
        -- 如果此时 CharacterFrame 不存在（极少见），尝试监听 ADDON_LOADED
        local listener = CreateFrame("Frame")
        listener:RegisterEvent("ADDON_LOADED")
        listener:SetScript("OnEvent", function(self, event, arg1)
            if CharacterFrame then
                EnsureMainFrameParent()
                self:UnregisterAllEvents()
            end
        end)
    end

    ITank.CharacterHooked = true
end

-- 斜杠命令
SLASH_ITANK1 = "/itank"
SlashCmdList["ITANK"] = function()
    local f = ITank.OptionsFrame or ITank.CreateOptionsFrame()
    if f:IsShown() then f:Hide() else f:Show() end
end

-- 初始化事件
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_TALENT_UPDATE")
eventFrame:RegisterEvent("CHARACTER_POINTS_CHANGED")
eventFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
eventFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
-- 外层不监听 UNIT_INVENTORY_CHANGED，避免高频无效失效

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- 确保 DB 初始化
        iTankDB = iTankDB or {}
        EnsureSEDBDefaults()
        if iTankDB.ShowTalentHit == nil then iTankDB.ShowTalentHit = true end
        if iTankDB.ShowRaceHit == nil then iTankDB.ShowRaceHit = true end
        if iTankDB.ShowSetHit == nil then iTankDB.ShowSetHit = true end
    elseif event == "PLAYER_LOGIN" then
        HookCharacterFrame()
        if ITank and ITank.Data and ITank.Data.GetShamanTalentHitSplit then
            ITank.Data.ShSplitCache = ITank.Data.ShSplitCache or { init = false }
        end
    elseif event == "PLAYER_TALENT_UPDATE" or event == "CHARACTER_POINTS_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        if ITank and ITank.Data and ITank.Data.ShSplitCache then
            ITank.Data.ShSplitCache.init = false
        end
    elseif event == "PLAYER_EQUIPMENT_CHANGED" then
        if ITank and ITank.Data and ITank.Data.InvalidateSetCache then ITank.Data:InvalidateSetCache() end
    end
end)

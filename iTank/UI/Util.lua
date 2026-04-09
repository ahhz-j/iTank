-- ============================================================================
-- UI 工具函数
-- 类别：UI 辅助（字体、通用按钮）
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}

-- 字体辅助函数
local function GetButtonFont()
    if ITank and ITank.Data and ITank.Data.GetUIFontFace then
        return ITank.Data:GetUIFontFace()
    end
    local f = STANDARD_TEXT_FONT
    if not f and GameFontNormal and GameFontNormal.GetFont then
        f = GameFontNormal:GetFont()
    end
    return f
end
local function GetFontFlags()
    if ITank and ITank.Data and ITank.Data.GetUIFontDefaults then
        local _, _, flags = ITank.Data:GetUIFontDefaults()
        return flags or "OUTLINE"
    end
    return "OUTLINE"
end

-- 创建开关按钮 (通用函数)
local function CreateToggleButton(parent, text, onClick, tooltipText)
    local btn = CreateFrame("Button", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    btn:SetSize(24, 24)
    btn:SetFrameStrata("HIGH") -- 确保按钮在最上层，避免被其他元素遮挡

    -- 使用与主面板一致的 Backdrop
    btn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 24, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    btn:SetBackdropColor(0, 0, 0, 1.0)

    -- 文字样式
    local fs = btn:CreateFontString(nil, "OVERLAY")
    fs:SetFont(GetButtonFont(), 14, GetFontFlags())
    fs:SetPoint("CENTER", btn, "CENTER", 0, 0)
    fs:SetJustifyH("CENTER")
    fs:SetJustifyV("MIDDLE")
    fs:SetText(text)

    -- 鼠标交互效果
    btn:EnableMouse(true)
    btn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 1.0)
        if tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tooltipText, 1, 1, 1)
            GameTooltip:Show()
        end
    end)
    btn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 1.0)
        if tooltipText then
            GameTooltip:Hide()
        end
    end)

    btn:SetScript("OnClick", onClick)
    return btn
end

-- 发布到全局命名空间供其他模块使用
ITank.GetButtonFont = GetButtonFont
ITank.GetFontFlags = GetFontFlags
ITank.CreateToggleButton = CreateToggleButton

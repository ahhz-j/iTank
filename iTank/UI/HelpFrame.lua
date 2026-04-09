-- ============================================================================
-- 帮助窗口
-- 类别：UI 面板（帮助）
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}

local function CreateHelpFrame()
    if ITank.HelpFrame then return ITank.HelpFrame end

    local f = CreateFrame("Frame", "ITankHelpFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(500, 350)
    f:SetPoint("CENTER")
    f:Hide()
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    local backdropInfo = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    f:SetBackdrop(backdropInfo)
    f:SetBackdropColor(0, 0, 0, 0.9)

    -- 标题
    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -16)
    f.title:SetText(L["HELP_TITLE"])

    -- 关闭按钮
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    -- 内容滚动框架
    local scrollFrame = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 16, -50)
    scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 16)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(450, 10) -- 高度将被调整
    scrollFrame:SetScrollChild(content)

    local fullText = L["HELP_CONTENT"] or ""
    if ITank and ITank.Data and ITank.Data.IsTBC and L["HELP_CONTENT_TBC"] then
        fullText = L["HELP_CONTENT_TBC"]
    end
    local separator = "--------------------------------------------------"
    local sStart, sEnd = string.find(fullText, separator, 1, true)

    local p1, p2
    if sStart then
        p1 = string.sub(fullText, 1, sEnd)
        p2 = string.sub(fullText, sEnd + 1)
    else
        p1 = fullText
        p2 = ""
    end

    local fs1 = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs1:SetWidth(430)
    fs1:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    fs1:SetJustifyH("LEFT")
    fs1:SetText(p1)

    local h1 = fs1:GetStringHeight()
    local totalHeight = h1 + 20

    if p2 and p2 ~= "" then
        local fs2 = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs2:SetWidth(430)
        fs2:SetPoint("TOPLEFT", fs1, "BOTTOMLEFT", 0, -10)
        fs2:SetJustifyH("CENTER")
        fs2:SetText(p2)

        local h2 = fs2:GetStringHeight()
        totalHeight = totalHeight + h2 + 10
    end

    content:SetHeight(totalHeight)

    ITank.HelpFrame = f
    return f
end

-- 发布到全局命名空间供其他模块使用
ITank.CreateHelpFrame = CreateHelpFrame

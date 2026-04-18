-- ============================================================================
-- 角色面板下方主界面
-- 类别：主 UI 容器（Basic/DPS/Defense 三段）
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}

local function CreateMainFrame()
    if ITank.MainFrame then return ITank.MainFrame end

    local parent = CharacterFrame or UIParent
    local f = CreateFrame("Frame", "ITankMainFrame", parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(440, 210)
    if iTankDB.MainOffsetX == nil then iTankDB.MainOffsetX = 13 end
    if iTankDB.MainOffsetY == nil then iTankDB.MainOffsetY = 40 end
    f:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", iTankDB.MainOffsetX, iTankDB.MainOffsetY)
    f:SetFrameStrata("BACKGROUND")
    f:EnableMouse(false)
    f:EnableKeyboard(false)
    f:Show()

    local HEIGHT_BASIC = iTankDB.BasicHeight or 50
    local HEIGHT_DPS = iTankDB.DPSHeight or 50
    local HEIGHT_DEFENSE = iTankDB.DefenseHeight or 95
    local FRAME_WIDTH = 440

    local backdropInfo = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    local framesConfig = {
        { key = "BasicFrame", height = HEIGHT_BASIC, relativeTo = f, point = "TOPLEFT", rPoint = "TOPLEFT" },
        { key = "DPSFrame", height = HEIGHT_DPS, relativeTo = "BasicFrame", point = "TOPLEFT", rPoint = "BOTTOMLEFT" },
        { key = "DefenseFrame", height = HEIGHT_DEFENSE, relativeTo = "DPSFrame", point = "TOPLEFT", rPoint = "BOTTOMLEFT" },
    }

    for _, cfg in ipairs(framesConfig) do
        local frame = CreateFrame("Frame", nil, f, BackdropTemplateMixin and "BackdropTemplate" or nil)
        frame:SetSize(FRAME_WIDTH, cfg.height)
        local rel = cfg.relativeTo
        if type(rel) == "string" then rel = f[rel] end
        frame:SetPoint(cfg.point, rel, cfg.rPoint, 0, 0)
        frame:SetBackdrop(backdropInfo)
        frame:SetBackdropColor(0, 0, 0, iTankDB.BackgroundAlpha or 0.9)
        f[cfg.key] = frame
    end

    local basicFrame = f.BasicFrame
    local dpsFrame = f.DPSFrame
    local defenseFrame = f.DefenseFrame

    local function UpdateLayout()
        dpsFrame:ClearAllPoints()
        defenseFrame:ClearAllPoints()
        local totalHeight = basicFrame:GetHeight()
        if dpsFrame:IsShown() then
            dpsFrame:SetPoint("TOPLEFT", basicFrame, "BOTTOMLEFT", 0, 0)
            defenseFrame:SetPoint("TOPLEFT", dpsFrame, "BOTTOMLEFT", 0, 0)
            totalHeight = totalHeight + dpsFrame:GetHeight()
        else
            defenseFrame:SetPoint("TOPLEFT", basicFrame, "BOTTOMLEFT", 0, 0)
        end
        if defenseFrame:IsShown() then totalHeight = totalHeight + defenseFrame:GetHeight() end
        f:SetHeight(totalHeight)
    end
    f.UpdateLayout = UpdateLayout

    function f:UpdatePosition()
        local p = CharacterFrame or UIParent
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", p, "BOTTOMLEFT", iTankDB.MainOffsetX or 13, iTankDB.MainOffsetY or 40)
    end

    f.ApplyVisibilitySettings = function(self)
        if self.manualShowDefense ~= nil then if self.manualShowDefense then defenseFrame:Show() else defenseFrame:Hide() end else defenseFrame:Show() end
        if self.manualShowDPS ~= nil then if self.manualShowDPS then dpsFrame:Show() else dpsFrame:Hide() end else dpsFrame:Show() end
        self:UpdateLayout()
    end

    f.pendingFullRefresh = false
    f.IsDataFrozen = function(self)
        if type(InCombatLockdown) == "function" then
            local ok, locked = pcall(InCombatLockdown)
            if ok and locked then return true end
        end
        if type(UnitAffectingCombat) == "function" then return UnitAffectingCombat("player") and true or false end
        return false
    end
    f.QueuePostCombatRefresh = function(self) self.pendingFullRefresh = true end

    f.UpdateDPSInfo = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end return end
        if not dpsFrame:IsShown() then return end
        local lines = ITank.Data:GetDPSPanelText()
        self.DPSLine1:SetText(lines.line1)
        self.DPSLine2:SetText(lines.line2)
        self.DPSLine3:SetText(lines.line3)
        if self.UpdateTextColor then self:UpdateTextColor() end
    end

    dpsFrame:SetScript("OnShow", function() f:UpdateDPSInfo() end)

    local btnHelp = ITank.CreateToggleButton(basicFrame, L["BUTTON_HELP"] or "?", function()
        local hf = ITank.HelpFrame or ITank.CreateHelpFrame()
        if hf:IsShown() then hf:Hide() else hf:Show(); if ITank.OptionsFrame and ITank.OptionsFrame:IsShown() then ITank.OptionsFrame:Hide() end end
    end, L["TOOLTIP_HELP"])
    btnHelp:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -25, 0)

    local btnSet = ITank.CreateToggleButton(basicFrame, L["BUTTON_SETTINGS"] or "S", function()
        local sf = ITank.OptionsFrame or ITank.CreateOptionsFrame()
        if sf:IsShown() then sf:Hide() else sf:Show(); local helpFrame = ITank.HelpFrame or ITank.CreateHelpFrame(); if helpFrame and helpFrame:IsShown() then helpFrame:Hide() end end
    end, L["TOOLTIP_SETTINGS"])
    btnSet:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -50, 0)

    local btnDef = ITank.CreateToggleButton(basicFrame, L["BUTTON_DEFENSE"] or "T", function()
        if defenseFrame:IsShown() then defenseFrame:Hide(); f.manualShowDefense = false; iTankDB.ShowDefense = false else defenseFrame:Show(); f.manualShowDefense = true; iTankDB.ShowDefense = true end
        UpdateLayout()
    end, L["TOOLTIP_DEFENSE"])
    btnDef:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -75, 0)

    do
        local btnSE = CreateFrame("Button", nil, basicFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
        btnSE:SetSize(24, 24)
        btnSE:SetFrameStrata("HIGH")
        btnSE:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 24, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
        btnSE:SetBackdropColor(0, 0, 0, iTankDB.BackgroundAlpha or 0.9)
        local tx = btnSE:CreateTexture(nil, "ARTWORK")
        tx:SetAllPoints()
        local seInfo = ITank.GetSEInfo()
        local texPath = iTankDB.SEIconPath or (seInfo and seInfo.iconPath)
        if texPath and texPath ~= "" then tx:SetTexture(texPath) end
        btnSE:EnableMouse(true)
        btnSE:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.3, 0.3, 0.3, iTankDB.BackgroundAlpha or 0.9)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local loc = GetLocale()
            local info = ITank.GetSEInfo()
            if info and info.text then
                local t = info.text[loc] or info.text.enUS
                if t and t.title then
                    GameTooltip:AddLine(t.title, 1.0, 0.41, 0.71, true)
                    if t.body and t.body ~= "" then GameTooltip:AddLine(t.body, 1, 1, 1, true) end
                end
            end
            GameTooltip:Show()
        end)
        btnSE:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, iTankDB.BackgroundAlpha or 0.9)
            GameTooltip:Hide()
        end)
        btnSE:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", 0, 0)
    end

    local btnDPS = ITank.CreateToggleButton(basicFrame, L["BUTTON_DPS"] or "D", function()
        if dpsFrame:IsShown() then dpsFrame:Hide(); f.manualShowDPS = false; iTankDB.ShowDPS = false else dpsFrame:Show(); f.manualShowDPS = true; iTankDB.ShowDPS = true end
        UpdateLayout()
    end, L["TOOLTIP_DPS"])
    btnDPS:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -100, 0)

    local currentFontSize = iTankDB.FontSize or 14
    local dpsLines = { "DPSLine1", "DPSLine2", "DPSLine3" }
    for _, key in ipairs(dpsLines) do
        local fs = dpsFrame:CreateFontString(nil, "OVERLAY")
        fs:SetFont(ITank.GetButtonFont(), currentFontSize, ITank.GetFontFlags())
        fs:SetJustifyH("LEFT")
        fs:SetTextColor(1, 0.75, 0.75)
        f[key] = fs
    end
    f.DPSLine2:SetPoint("LEFT", dpsFrame, "LEFT", 10, 0)
    f.DPSLine1:SetPoint("BOTTOMLEFT", f.DPSLine2, "TOPLEFT", 0, 0)
    f.DPSLine3:SetPoint("TOPLEFT", f.DPSLine2, "BOTTOMLEFT", 0, 0)

    local defenseLayout = {
        { key = "DefCol1", anchor = {"LEFT", defenseFrame, "LEFT", 10, 0} },
        { key = "DefCol2", anchor = {"TOPLEFT", "DefCol1", "TOPLEFT", 120, 0} },
        { key = "DefCol3", anchor = {"TOPLEFT", "DefCol1", "TOPLEFT", 270, 0} },
    }
    for _, item in ipairs(defenseLayout) do
        local fs = defenseFrame:CreateFontString(nil, "OVERLAY")
        fs:SetFont(ITank.GetButtonFont(), currentFontSize, ITank.GetFontFlags())
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        fs:SetTextColor(1, 0.75, 0.75)
        local p, rel, rp, x, y = unpack(item.anchor)
        if type(rel) == "string" then rel = f[rel] end
        fs:SetPoint(p, rel, rp, x, y)
        f[item.key] = fs
    end

    f.UpdateDefenseInfo = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end return end
        if not defenseFrame:IsShown() then return end
        local texts = ITank.Data:GetDefensePanelText()
        self.DefCol1:SetText(texts.col1)
        self.DefCol2:SetText(texts.col2)
        self.DefCol3:SetText(texts.col3)
        if self.UpdateTextColor then self:UpdateTextColor() end
    end

    f.UpdateBackdropColor = function(self)
        local a = iTankDB.BackgroundAlpha or 0.9
        local r, g, b = 0, 0, 0
        if type(iTankDB.BackgroundRGB) == "table" then r = iTankDB.BackgroundRGB[1] or 0; g = iTankDB.BackgroundRGB[2] or 0; b = iTankDB.BackgroundRGB[3] or 0 end
        for _, k in ipairs({ "BasicFrame", "DPSFrame", "DefenseFrame" }) do
            if self[k] then
                self[k]:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", tile = true, tileSize = 16, edgeSize = 0, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
                if self[k].SetBackdropColor then self[k]:SetBackdropColor(r, g, b, a) end
            end
        end
    end

    f.UpdateTextColor = function(self)
        local r, g, b = 1, 1, 1
        if type(iTankDB.TextRGB) == "table" then r = iTankDB.TextRGB[1] or 1; g = iTankDB.TextRGB[2] or 1; b = iTankDB.TextRGB[3] or 1 end
        for _, k in ipairs({ "DPSLine1", "DPSLine2", "DPSLine3", "DefCol1", "DefCol2", "DefCol3", "BasicInfoLine1_1", "BasicInfoLine1_2", "BasicInfoLine2_1", "BasicInfoLine2_2", "BasicInfoLine2_3", "BasicInfoLine3_1", "BasicInfoLine3_2", "BasicInfoLine3_3", "BasicInfoLine3_4" }) do
            if self[k] then self[k]:SetTextColor(r, g, b) end
        end
    end

    if iTankDB.ShowDefense ~= nil then f.manualShowDefense = iTankDB.ShowDefense and true or false end
    if iTankDB.ShowDPS ~= nil then f.manualShowDPS = iTankDB.ShowDPS and true or false end
    if f.ApplyVisibilitySettings then f:ApplyVisibilitySettings() end
    if f.UpdateBackdropColor then f:UpdateBackdropColor() end
    if f.UpdateTextColor then f:UpdateTextColor() end

    ITank.MainFrame = f
    return f
end

ITank.CreateMainFrame = CreateMainFrame

-- ============================================================================
-- 主设置面板
-- 类别：设置 UI 总装配（包含侧边栏与多内容页）
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}

local function CreateOptionsFrame()
    if ITank.OptionsFrame then return ITank.OptionsFrame end

    local FRAME_WIDTH = 700
    local FRAME_HEIGHT = 400
    local TITLE_HEIGHT = 30
    local SIDEBAR_WIDTH = 150
    local CONTENT_WIDTH = FRAME_WIDTH - SIDEBAR_WIDTH

    -- 使用 BackdropTemplate 以匹配主界面风格
    local f = CreateFrame("Frame", "ITankOptionsFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    f:SetPoint("CENTER")
    f:Hide()
    f:SetFrameStrata("DIALOG")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")

    local backdropInfo = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    f:SetBackdrop(backdropInfo)
    f:SetBackdropColor(0, 0, 0, 0.9)

    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetSize(FRAME_WIDTH, TITLE_HEIGHT)
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    titleBar.text = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleBar.text:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleBar.text:SetText(L["OPTIONS_TITLE"])

    local versionText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("RIGHT", titleBar, "RIGHT", -TITLE_HEIGHT - 5, 0)
    do
        local label = ""
        if ITank and ITank.Data and ITank.Data.GetGameVersionLabel then
            label = ITank.Data:GetGameVersionLabel() or ""
        end
        versionText:SetText(string.format(L["VERSION_SHORT"], ITank.VERSION) .. (label ~= "" and ("(" .. label .. ")") or ""))
    end

    local closeBtn = CreateFrame("Button", nil, titleBar, BackdropTemplateMixin and "BackdropTemplate" or nil)
    closeBtn:SetSize(TITLE_HEIGHT, TITLE_HEIGHT)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 0)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    closeBtn:SetBackdropColor(0, 0, 0, 0)

    local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(ITank.GetButtonFont(), 14, ITank.GetFontFlags())
    closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeText:SetText("X")
    closeText:SetTextColor(1, 1, 1)

    closeBtn:EnableMouse(true)
    closeBtn:SetScript("OnEnter", function(self) self:SetBackdropColor(0.3, 0.3, 0.3, 0.8) end)
    closeBtn:SetScript("OnLeave", function(self) self:SetBackdropColor(0, 0, 0, 0) end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    local hLine = f:CreateTexture(nil, "ARTWORK")
    hLine:SetHeight(1)
    hLine:SetWidth(FRAME_WIDTH - 10)
    hLine:SetPoint("TOP", titleBar, "BOTTOM", 0, 0)
    hLine:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    local vLine = f:CreateTexture(nil, "ARTWORK")
    vLine:SetWidth(1)
    vLine:SetPoint("TOPLEFT", f, "TOPLEFT", SIDEBAR_WIDTH, -TITLE_HEIGHT - 5)
    vLine:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", SIDEBAR_WIDTH, 5)
    vLine:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -TITLE_HEIGHT - 5)
    sidebar:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", SIDEBAR_WIDTH, 5)

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", SIDEBAR_WIDTH + 5, -TITLE_HEIGHT - 5)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)

    local panels = {}
    local function CreateContentPanel(name)
        local p = CreateFrame("Frame", nil, content)
        p:SetAllPoints()
        p:Hide()
        panels[name] = p
        return p
    end

    local selectedBtn = nil
    local function CreateSidebarButton(text, panelName, index)
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_WIDTH - 10, 25)
        btn:SetPoint("TOP", sidebar, "TOP", 0, -((index - 1) * 25) - 10)
        local fs = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint("LEFT", btn, "LEFT", 10, 0)
        fs:SetText(text)
        btn.fs = fs
        local highlight = btn:CreateTexture(nil, "BACKGROUND")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, 0.1)
        highlight:Hide()
        btn.highlight = highlight
        btn:SetScript("OnEnter", function() highlight:Show() end)
        btn:SetScript("OnLeave", function() if selectedBtn ~= btn then highlight:Hide() end end)
        btn:SetScript("OnClick", function()
            for _, p in pairs(panels) do p:Hide() end
            if panels[panelName] then panels[panelName]:Show() end
            if selectedBtn then
                selectedBtn.fs:SetTextColor(1, 0.82, 0)
                selectedBtn.highlight:Hide()
            end
            selectedBtn = btn
            btn.fs:SetTextColor(1, 1, 1)
            btn.highlight:Show()
        end)
        return btn
    end

    local panelInterface = CreateContentPanel("Interface")

    local function CreateCheckButton(parent, label, dbKey, relativeTo, x, y, onClick)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        if relativeTo then cb:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y) else cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y) end
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        cb.text:SetText(label)
        cb:SetChecked(iTankDB[dbKey])
        cb:SetScript("OnClick", function(self)
            iTankDB[dbKey] = self:GetChecked()
            if onClick then onClick() end
        end)
        return cb
    end

    local function CreateLabeledSlider(anchorFS, spec)
        local titleFS = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFS:SetPoint("TOPLEFT", anchorFS, "BOTTOMLEFT", spec.offsetX or 0, spec.offsetY or -8)
        titleFS:SetText(spec.title)
        local slider = CreateFrame("Slider", spec.name, panelInterface, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", titleFS, "TOPLEFT", 200, 0)
        slider:SetWidth(200)
        slider:SetHeight(17)
        slider:SetMinMaxValues(spec.min, spec.max)
        slider:SetValueStep(spec.step)
        if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
        slider:SetValue(spec.get())
        _G[slider:GetName() .. "Low"]:SetText(spec.lowLabel)
        _G[slider:GetName() .. "High"]:SetText(spec.highLabel)
        _G[slider:GetName() .. "Text"]:SetText(spec.format(spec.get()))
        slider:SetScript("OnValueChanged", function(self, value)
            local stepped = spec.round(value)
            if math.abs(value - stepped) > 0.1 then self:SetValue(stepped); return end
            _G[self:GetName() .. "Text"]:SetText(spec.format(stepped))
            spec.set(stepped)
        end)
        return titleFS
    end

    local fontTitle = CreateLabeledSlider((function() local fs = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal"); fs:SetPoint("TOPLEFT", panelInterface, "TOPLEFT", 20, -10); return fs end)(), {
        name = "ITankFontSizeSlider",
        title = L["SETTING_FONT_SIZE_TITLE"], min = 10, max = 16, step = 1, lowLabel = "10", highLabel = "16",
        get = function() return iTankDB.FontSize or 14 end,
        set = function(v) if (iTankDB.FontSize or 14) ~= v then iTankDB.FontSize = v; if ITank.MainFrame and ITank.MainFrame.UpdateFontSize then ITank.MainFrame:UpdateFontSize() end end end,
        format = function(v) return string.format(L["SETTING_FONT_SIZE_FMT"] or "%d", v) end,
        round = function(v) return math.floor(v + 0.5) end,
        offsetY = 0
    })

    local alphaTitle = CreateLabeledSlider(fontTitle, {
        name = "ITankAlphaSlider",
        title = L["SETTING_BG_ALPHA_TITLE"], min = 0, max = 100, step = 10, lowLabel = "0%", highLabel = "100%",
        get = function() return (1 - (iTankDB.BackgroundAlpha or 0.9)) * 100 end,
        set = function(stepped)
            local newAlpha = 1 - (stepped / 100)
            if math.abs((iTankDB.BackgroundAlpha or 0.9) - newAlpha) > 0.001 then
                iTankDB.BackgroundAlpha = newAlpha
                if ITank.MainFrame and ITank.MainFrame.UpdateBackdropColor then ITank.MainFrame:UpdateBackdropColor() end
            end
        end,
        format = function(v) return string.format(L["SETTING_BG_ALPHA_FMT"], v) end,
        round = function(v) return math.floor(v / 10 + 0.5) * 10 end,
        offsetY = -8
    })

    local panelData = CreateContentPanel("Data")
    local panelAboutHit = CreateContentPanel("AboutHit")
    local panelAboutAddon = CreateContentPanel("AboutAddon")
    local panelSpecialThanks = CreateContentPanel("SpecialThanks")
    local panelAboutUs = CreateContentPanel("AboutUs")

    local menus = {
        { L["MENU_INTERFACE"] or "界面选项", "Interface" },
        { L["MENU_DATA"] or "数据选项", "Data" },
        { L["MENU_ABOUT_HIT"] or "关于命中", "AboutHit" },
        { L["MENU_ABOUT_ADDON"] or "关于插件", "AboutAddon" },
        { L["MENU_SPECIAL_THANKS"] or "特别致谢", "SpecialThanks" },
        { L["MENU_ABOUT_US"] or "关于我们", "AboutUs" },
    }
    local btn1
    for i, item in ipairs(menus) do
        local b = CreateSidebarButton(item[1], item[2], i)
        if i == 1 then btn1 = b end
    end
    btn1:GetScript("OnClick")(btn1)

    ITank.OptionsFrame = f
    return f
end

ITank.CreateOptionsFrame = CreateOptionsFrame

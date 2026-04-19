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
        tile = true, tileSize = 16, edgeSize = 0, -- Removed edgeFile and set edgeSize to 0
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    }
    f:SetBackdrop(backdropInfo)
    f:SetBackdropColor(0, 0, 0, 0.9)

    -- 标题栏（标题/版本/关闭）
    -- 类别：设置 UI - 标题区
    local titleBar = CreateFrame("Frame", nil, f)
    titleBar:SetSize(FRAME_WIDTH, TITLE_HEIGHT)
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)

    -- 允许通过标题栏拖动
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() f:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() f:StopMovingOrSizing() end)

    -- 标题文字
    titleBar.text = titleBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    titleBar.text:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleBar.text:SetText(L["OPTIONS_TITLE"])

    -- 版本号 (显示在标题栏右侧)
    local versionText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    versionText:SetPoint("RIGHT", titleBar, "RIGHT", -TITLE_HEIGHT - 5, 0)
    do
        local label = ""
        if ITank and ITank.Data and ITank.Data.GetGameVersionLabel then
            label = ITank.Data:GetGameVersionLabel() or ""
        end
        versionText:SetText(string.format(L["VERSION_SHORT"], ITank.VERSION) .. (label ~= "" and ("(" .. label .. ")") or ""))
    end

    -- 关闭按钮 (自定义黑白风格)
    local closeBtn = CreateFrame("Button", nil, titleBar, BackdropTemplateMixin and "BackdropTemplate" or nil)
    closeBtn:SetSize(TITLE_HEIGHT, TITLE_HEIGHT)
    closeBtn:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 0)

    closeBtn:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    closeBtn:SetBackdropColor(0, 0, 0, 0) -- 默认透明

    local closeText = closeBtn:CreateFontString(nil, "OVERLAY")
    closeText:SetFont(ITank.GetButtonFont(), 14, ITank.GetFontFlags())
    closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeText:SetText("X")
    closeText:SetTextColor(1, 1, 1) -- 白色文字

    closeBtn:EnableMouse(true)
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 0.8) -- 悬停高亮
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0)
    end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- 分隔线 (标题栏下方)
    local hLine = f:CreateTexture(nil, "ARTWORK")
    hLine:SetHeight(1)
    hLine:SetWidth(FRAME_WIDTH - 10)
    hLine:SetPoint("TOP", titleBar, "BOTTOM", 0, 0)
    hLine:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- 左右分栏分隔线
    local vLine = f:CreateTexture(nil, "ARTWORK")
    vLine:SetWidth(1)
    vLine:SetPoint("TOPLEFT", f, "TOPLEFT", SIDEBAR_WIDTH, -TITLE_HEIGHT - 5)
    vLine:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", SIDEBAR_WIDTH, 5)
    vLine:SetColorTexture(0.5, 0.5, 0.5, 0.5)

    -- 左侧菜单容器
    -- 类别：设置 UI - 导航
    local sidebar = CreateFrame("Frame", nil, f)
    sidebar:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -TITLE_HEIGHT - 5)
    sidebar:SetPoint("BOTTOMRIGHT", f, "BOTTOMLEFT", SIDEBAR_WIDTH, 5)

    -- 右侧内容容器
    -- 类别：设置 UI - 内容区
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", SIDEBAR_WIDTH + 5, -TITLE_HEIGHT - 5)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -5, 5)

    -- 内容面板列表
    -- 类别：设置 UI - 面板注册
    local panels = {}

    -- 辅助函数：创建内容面板
    -- 类别：设置 UI - 工具
    local function CreateContentPanel(name)
        local p = CreateFrame("Frame", nil, content)
        p:SetAllPoints()
        p:Hide()
        panels[name] = p
        return p
    end

    -- 辅助函数：创建侧边栏按钮
    -- 类别：设置 UI - 工具
    local selectedBtn = nil
    local function CreateSidebarButton(text, panelName, index)
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(SIDEBAR_WIDTH - 10, 25) -- Reduced height for compact layout
        btn:SetPoint("TOP", sidebar, "TOP", 0, -((index - 1) * 25) - 10) -- Reduced vertical spacing

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
            -- 切换面板
            for k, p in pairs(panels) do p:Hide() end
            if panels[panelName] then panels[panelName]:Show() end

            -- 更新按钮状态
            if selectedBtn then
                selectedBtn.fs:SetTextColor(1, 0.82, 0) -- GameFontNormal Color
                selectedBtn.highlight:Hide()
            end
            selectedBtn = btn
            btn.fs:SetTextColor(1, 1, 1) -- White
            btn.highlight:Show()
        end)

        return btn
    end

    -- ========================================================================
    -- 1. 界面面板 (Interface)
    -- 类别：设置 UI - 外观
    -- ========================================================================
    local panelInterface = CreateContentPanel("Interface")

    -- 复选框辅助函数
    local function CreateCheckButton(parent, label, dbKey, relativeTo, x, y, onClick)
        local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
        if relativeTo then
            cb:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", x, y)
        else
            cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        end
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
    local fontTitle = CreateLabeledSlider(
        (function() local fs = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal"); fs:SetPoint("TOPLEFT", panelInterface, "TOPLEFT", 20, -10); return fs end)(),
        {
            name = "ITankFontSizeSlider",
            title = L["SETTING_FONT_SIZE_TITLE"],
            min = 10, max = 16, step = 1, lowLabel = "10", highLabel = "16",
            get = function() return iTankDB.FontSize or 14 end,
            set = function(v) if (iTankDB.FontSize or 14) ~= v then iTankDB.FontSize = v; if ITank.MainFrame and ITank.MainFrame.UpdateFontSize then ITank.MainFrame:UpdateFontSize() end end end,
            format = function(v) return string.format(L["SETTING_FONT_SIZE_FMT"] or "%d", v) end,
            round = function(v) return math.floor(v + 0.5) end,
            offsetY = -0
        }
    )
    local alphaTitle = CreateLabeledSlider(
        fontTitle,
        {
            name = "ITankAlphaSlider",
            title = L["SETTING_BG_ALPHA_TITLE"],
            min = 0, max = 100, step = 10, lowLabel = "0%", highLabel = "100%",
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
        }
    )

    -- 背景颜色选择
    -- 类别：设置 UI - 背景颜色（依赖 MainFrame:UpdateBackdropColor）
    local colorTitle = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    colorTitle:SetPoint("TOPLEFT", alphaTitle, "BOTTOMLEFT", 0, -12)
    colorTitle:SetText(L["SETTING_BG_COLOR"] or "背景颜色")

    local colorSwatch = CreateFrame("Button", nil, panelInterface, BackdropTemplateMixin and "BackdropTemplate" or nil)
    colorSwatch:SetSize(24, 24)
    colorSwatch:SetPoint("LEFT", colorTitle, "RIGHT", 8, 0)
    colorSwatch:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    local function GetBGColor()
        local c = iTankDB.BackgroundRGB
        if type(c) == "table" then return c[1] or 0, c[2] or 0, c[3] or 0 end
        return 0, 0, 0
    end
    local function SetSwatchColor()
        local r, g, b = GetBGColor()
        colorSwatch:SetBackdropColor(r, g, b, 1)
        colorSwatch:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    end
    SetSwatchColor()
    colorSwatch:SetScript("OnClick", function()
        local bgR, bgG, bgB = GetBGColor()
        if ColorPickerFrame and ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:Hide()
            ColorPickerFrame.hasOpacity = false
            local function applyBgColor(nr, ng, nb)
                iTankDB.BackgroundRGB = { nr, ng, nb }
                SetSwatchColor()
                if ITank.MainFrame and ITank.MainFrame.UpdateBackdropColor then ITank.MainFrame:UpdateBackdropColor() end
            end
            ColorPickerFrame.ITankApplyFn = applyBgColor
            ColorPickerFrame.func = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                if ColorPickerFrame.ITankApplyFn then ColorPickerFrame.ITankApplyFn(nr, ng, nb) end
            end
            if ColorPickerFrame.CancelButton then
                ColorPickerFrame.cancelFunc = function(prev)
                    local pr, pg, pb = bgR, bgG, bgB
                    if type(prev) == "table" then pr, pg, pb = prev.r or bgR, prev.g or bgG, prev.b or bgB end
                    applyBgColor(pr, pg, pb)
                end
            end
            ColorPickerFrame:SetColorRGB(bgR, bgG, bgB)
            ColorPickerFrame.previousValues = { r = bgR, g = bgG, b = bgB }
            if not ColorPickerFrame.ITankHooked then
                ColorPickerFrame:HookScript("OnColorSelect", function(_, nr, ng, nb)
                    if ColorPickerFrame.ITankApplyFn then ColorPickerFrame.ITankApplyFn(nr, ng, nb) end
                end)
                ColorPickerFrame.ITankHooked = true
            end
            ColorPickerFrame:Show()
        end
    end)

    -- 文字颜色选择
    -- 类别：设置 UI - 文字颜色（依赖 MainFrame:UpdateTextColor）
    local textColorTitle = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    textColorTitle:SetPoint("TOPLEFT", colorTitle, "BOTTOMLEFT", 0, -12)
    textColorTitle:SetText(L["SETTING_TEXT_COLOR"] or "文字颜色")

    local textColorSwatch = CreateFrame("Button", nil, panelInterface, BackdropTemplateMixin and "BackdropTemplate" or nil)
    textColorSwatch:SetSize(24, 24)
    textColorSwatch:SetPoint("LEFT", textColorTitle, "RIGHT", 8, 0)
    textColorSwatch:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    local function GetTextColor()
        local c = iTankDB.TextRGB
        if type(c) == "table" then return c[1] or 1, c[2] or 1, c[3] or 1 end
        return 1, 1, 1
    end
    local function SetTextSwatchColor()
        local r, g, b = GetTextColor()
        textColorSwatch:SetBackdropColor(r, g, b, 1)
        textColorSwatch:SetBackdropBorderColor(0.8, 0.8, 0.8, 1)
    end
    SetTextSwatchColor()
    textColorSwatch:SetScript("OnClick", function()
        local textR, textG, textB = GetTextColor()
        if ColorPickerFrame and ColorPickerFrame.SetColorRGB then
            ColorPickerFrame:Hide()
            ColorPickerFrame.hasOpacity = false
            local function applyTextColor(nr, ng, nb)
                iTankDB.TextRGB = { nr, ng, nb }
                SetTextSwatchColor()
                if ITank.MainFrame and ITank.MainFrame.UpdateTextColor then ITank.MainFrame:UpdateTextColor() end
            end
            ColorPickerFrame.ITankApplyFn = applyTextColor
            ColorPickerFrame.func = function()
                local nr, ng, nb = ColorPickerFrame:GetColorRGB()
                if ColorPickerFrame.ITankApplyFn then ColorPickerFrame.ITankApplyFn(nr, ng, nb) end
            end
            if ColorPickerFrame.CancelButton then
                ColorPickerFrame.cancelFunc = function(prev)
                    local pr, pg, pb = textR, textG, textB
                    if type(prev) == "table" then pr, pg, pb = prev.r or textR, prev.g or textG, prev.b or textB end
                    applyTextColor(pr, pg, pb)
                end
            end
            ColorPickerFrame:SetColorRGB(textR, textG, textB)
            ColorPickerFrame.previousValues = { r = textR, g = textG, b = textB }
            if not ColorPickerFrame.ITankHooked then
                ColorPickerFrame:HookScript("OnColorSelect", function(_, nr, ng, nb)
                    if ColorPickerFrame.ITankApplyFn then ColorPickerFrame.ITankApplyFn(nr, ng, nb) end
                end)
                ColorPickerFrame.ITankHooked = true
            end
            ColorPickerFrame:Show()
        end
    end)

    local lastFS = textColorTitle
    local sliders = {
        { key = "BasicHeight", title = "基础信息面板高度", min = 30, max = 60, step = 2, low = "30", high = "60", def = 50, frameKey = "BasicFrame" },
        { key = "DPSHeight", title = "iDPS面板高度", min = 30, max = 60, step = 2, low = "30", high = "60", def = 50, frameKey = "DPSFrame" },
        { key = "DefenseHeight", title = "防御面板高度", min = 50, max = 100, step = 2, low = "50", high = "100", def = 95, frameKey = "DefenseFrame" },
    }
    for idx, s in ipairs(sliders) do
        local titleFS = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        titleFS:SetPoint("TOPLEFT", lastFS, "BOTTOMLEFT", 0, idx == 1 and -16 or -15)
        titleFS:SetText(s.title)
        local slider = CreateFrame("Slider", "ITankSlider_"..s.key, panelInterface, "OptionsSliderTemplate")
        slider:SetPoint("TOPLEFT", titleFS, "TOPLEFT", 200, 0)
        slider:SetWidth(200)
        slider:SetHeight(17)
        slider:SetMinMaxValues(s.min, s.max)
        slider:SetValueStep(s.step)
        if slider.SetObeyStepOnDrag then slider:SetObeyStepOnDrag(true) end
        local cur = iTankDB[s.key] or s.def
        slider:SetValue(cur)
        _G[slider:GetName() .. "Low"]:SetText(s.low)
        _G[slider:GetName() .. "High"]:SetText(s.high)
        _G[slider:GetName() .. "Text"]:SetText(string.format("%d", cur))
        slider:SetScript("OnValueChanged", function(self, value)
            local stepped = math.floor(value / s.step + 0.5) * s.step
            if math.abs(value - stepped) > 0.1 then self:SetValue(stepped); return end
            _G[self:GetName() .. "Text"]:SetText(string.format("%d", stepped))
            iTankDB[s.key] = stepped
            if ITank.MainFrame and ITank.MainFrame[s.frameKey] then
                ITank.MainFrame[s.frameKey]:SetHeight(stepped)
                if ITank.MainFrame.UpdateLayout then ITank.MainFrame:UpdateLayout() end
            end
        end)
        lastFS = titleFS
    end

    -- 主界面位置微调（2px 步进）
    local posTitle = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    posTitle:SetPoint("TOPLEFT", lastFS, "BOTTOMLEFT", 0, -20)
    posTitle:SetText("主界面位置")
    local coordLabel = panelInterface:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    coordLabel:SetPoint("LEFT", posTitle, "RIGHT", 10, 0)
    local function RefreshCoordLabel()
        local ox = iTankDB.MainOffsetX or 13
        local oy = iTankDB.MainOffsetY or 40
        coordLabel:SetText(string.format("(x:%d, y:%d)", ox, oy))
    end
    RefreshCoordLabel()
    local function Nudge(dx, dy)
        iTankDB.MainOffsetX = (iTankDB.MainOffsetX or 13) + dx
        iTankDB.MainOffsetY = (iTankDB.MainOffsetY or 40) + dy
        if ITank.MainFrame and ITank.MainFrame.UpdatePosition then
            ITank.MainFrame:UpdatePosition()
        end
        RefreshCoordLabel()
    end
    local buttons = {
        { label = "↑", anchor = { "TOPLEFT", posTitle, "BOTTOMLEFT", 40, -8 }, dx = 0, dy = 2 },
        { label = "←", anchor = { "TOPRIGHT", "$prev", "BOTTOMLEFT", -4, -4 }, dx = -2, dy = 0 },
        { label = "→", anchor = { "TOPLEFT", "$first", "BOTTOMRIGHT", 4, -4 }, dx = 2, dy = 0 },
        { label = "↓", anchor = { "TOP", "$first", "BOTTOM", 0, -28 }, dx = 0, dy = -2 },
    }
    local firstBtn, prevBtn
    for i, b in ipairs(buttons) do
        local btn = CreateFrame("Button", nil, panelInterface, "UIPanelButtonTemplate")
        btn:SetSize(24, 20)
        local a1, ar, a2, ax, ay = unpack(b.anchor)
        if ar == "$prev" then ar = prevBtn end
        if ar == "$first" then ar = firstBtn end
        btn:SetPoint(a1, ar, a2, ax, ay)
        btn:SetText(b.label)
        btn:SetScript("OnClick", function() Nudge(b.dx, b.dy) end)
        if not firstBtn then firstBtn = btn end
        prevBtn = btn
    end

    -- ========================================================================
    -- 2. 数据面板 (Data)
    -- 类别：设置 UI - 数据显示控制（命中/套装/种族开关）
    -- ========================================================================
    local panelData = CreateContentPanel("Data")

    -- 数据选项表单化：天赋/套装/种族/套装信息/技能等级
    local function appendUnavailable(fs)
        local note = L["UNAVAILABLE_IN_VERSION"] or ""
        local cur = fs:GetText() or ""
        if note ~= "" and not string.find(cur, note, 1, true) then
            fs:SetText(cur .. note)
        end
    end
    local checkSpecs = {
        { key="ShowTalentHit",   label=L["SETTING_SHOW_TALENT_HIT"],   dpsUpdate=true,
          disable=function() return ITank and ITank.Data and ITank.Data.IsMOP end, noteOnDisable=true },
        { key="ShowSetHit",      label=L["SETTING_SHOW_SET_HIT"],      dpsUpdate=true,
          disable=function()
              return ITank and ITank.Data and (ITank.Data.IsTBC or ITank.Data.IsMOP)
          end, noteOnDisable=function() return ITank and ITank.Data and ITank.Data.IsMOP end },
        { key="ShowRaceHit",     label=L["SETTING_SHOW_RACE_HIT"],     dpsUpdate=true },
        { key="ShowSets",        label=L["SETTING_SHOW_SETS"],         dpsUpdate=true },
        { key="HideIDPSSkillLevel", label=L["SETTING_HIDE_IDPS_SKILL_LEVEL"], dpsUpdate=false,
          forceDisabled=true },
    }
    local lastCB
    for idx, spec in ipairs(checkSpecs) do
        local cb = CreateCheckButton(panelData, spec.label, spec.key, lastCB, idx == 1 and 20 or 0, idx == 1 and 0 or -5, function()
            if spec.dpsUpdate and ITank.MainFrame then ITank.MainFrame:UpdateDPSInfo() end
        end)
        lastCB = cb
        if spec.forceDisabled then
            cb:Disable()
            cb.text:SetTextColor(0.5, 0.5, 0.5)
        elseif spec.disable and spec.disable() then
            cb:Disable()
            cb.text:SetTextColor(0.5, 0.5, 0.5)
            iTankDB[spec.key] = false
            cb:SetChecked(false)
            local noteNeeded = (type(spec.noteOnDisable) == "function") and spec.noteOnDisable() or spec.noteOnDisable
            if noteNeeded then appendUnavailable(cb.text) end
        end
    end
    local cbSkillLevel = lastCB

    -- 选项：DK命中模式（死亡骑士专用，阈值 8/14 联动）
    local dkHitTitle = panelData:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dkHitTitle:SetPoint("TOPLEFT", cbSkillLevel, "BOTTOMLEFT", 0, -10)
    dkHitTitle:SetText(L["SETTING_DK_HIT_MODE"])
    local function CreateRadio(parent, anchor, text)
        local rb = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
        rb:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 10, -5)
        rb.text = rb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        rb.text:SetPoint("LEFT", rb, "RIGHT", 5, 0)
        rb.text:SetText(text)
        return rb
    end
    local rbDKPhys = CreateRadio(panelData, dkHitTitle, L["SETTING_DK_HIT_PHYSICAL"])
    local rbDKSpell = CreateFrame("CheckButton", nil, panelData, "UIRadioButtonTemplate")
    rbDKSpell:SetPoint("LEFT", rbDKPhys, "RIGHT", 120, 0)
    rbDKSpell.text = rbDKSpell:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    rbDKSpell.text:SetPoint("LEFT", rbDKSpell, "RIGHT", 5, 0)
    rbDKSpell.text:SetText(L["SETTING_DK_HIT_SPELL"])
    rbDKPhys:SetScript("OnClick", function(self) iTankDB.DKHitMode = 1; self:SetChecked(true); rbDKSpell:SetChecked(false) end)
    rbDKSpell:SetScript("OnClick", function(self) iTankDB.DKHitMode = 2; self:SetChecked(true); rbDKPhys:SetChecked(false) end)

    -- 初始化选中状态
    local function InitDKHitRadio()
        local mode = iTankDB.DKHitMode
        if mode == nil then
            -- 迁移旧数据
            if iTankDB.DKHitPhysical then
                mode = 1
            else
                mode = 2 -- 默认法术
            end
            iTankDB.DKHitMode = mode
        end

        if mode == 1 then
            rbDKPhys:SetChecked(true)
            rbDKSpell:SetChecked(false)
        else
            rbDKPhys:SetChecked(false)
            rbDKSpell:SetChecked(true)
        end
    end
    InitDKHitRadio()
    -- 非死亡骑士：禁用该选项
    do
        local _, classEn = UnitClass("player")
        if classEn ~= "DEATHKNIGHT" then
            rbDKPhys:Disable(); rbDKSpell:Disable()
            rbDKPhys.text:SetTextColor(0.5, 0.5, 0.5)
            rbDKSpell.text:SetTextColor(0.5, 0.5, 0.5)
            dkHitTitle:SetTextColor(0.5, 0.5, 0.5)
            local note = L["UNAVAILABLE_FOR_CLASS"] or ""
            local cur = dkHitTitle:GetText() or ""
            if note ~= "" and not string.find(cur, note, 1, true) then
                dkHitTitle:SetText(cur .. note)
            end
        end
    end
    -- MOP: Disable DK hit mode (not applicable) and append note
    if ITank and ITank.Data and ITank.Data.IsMOP then
        rbDKPhys:Disable(); rbDKSpell:Disable()
        rbDKPhys.text:SetTextColor(0.5, 0.5, 0.5)
        rbDKSpell.text:SetTextColor(0.5, 0.5, 0.5)
        dkHitTitle:SetTextColor(0.5, 0.5, 0.5)
        appendUnavailable(dkHitTitle)
    end

    -- ========================================================================
    -- 3. 关于命中 (About Hit)
    -- 类别：说明文档（版本化命中机制），可迁移至 Docs 或 templates
    -- ========================================================================
    local panelAboutHit = CreateContentPanel("AboutHit")

    local scrollHit = CreateFrame("ScrollFrame", nil, panelAboutHit, "UIPanelScrollFrameTemplate")
    scrollHit:SetPoint("TOPLEFT", panelAboutHit, "TOPLEFT", 10, -10)
    scrollHit:SetPoint("BOTTOMRIGHT", panelAboutHit, "BOTTOMRIGHT", -30, 10)

    local contentHit = CreateFrame("Frame", nil, scrollHit)
    contentHit:SetSize(CONTENT_WIDTH - 40, 10)
    scrollHit:SetScrollChild(contentHit)

    local hitText = L["INFO_HIT"] or ""
    if ITank and ITank.Data then
        if ITank.Data.IsTBC and L["INFO_HIT_TBC"] then
            hitText = L["INFO_HIT_TBC"]
        elseif ITank.Data.IsMOP and L["INFO_HIT_MOP"] then
            hitText = L["INFO_HIT_MOP"]
        end
    end
    local fsHit = contentHit:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fsHit:SetWidth(CONTENT_WIDTH - 50)
    fsHit:SetPoint("TOPLEFT", contentHit, "TOPLEFT", 0, 0)
    fsHit:SetJustifyH("LEFT")
    fsHit:SetText(hitText)

    contentHit:SetHeight(fsHit:GetStringHeight() + 20)

    -- ========================================================================
    -- 4. 关于插件 (About Addon)
    -- 类别：说明文档（插件简介），可迁移至 Docs 或 templates
    -- ========================================================================
    local panelAboutAddon = CreateContentPanel("AboutAddon")

    local scrollAddon = CreateFrame("ScrollFrame", nil, panelAboutAddon, "UIPanelScrollFrameTemplate")
    scrollAddon:SetPoint("TOPLEFT", panelAboutAddon, "TOPLEFT", 10, -10)
    scrollAddon:SetPoint("BOTTOMRIGHT", panelAboutAddon, "BOTTOMRIGHT", -30, 10)

    local contentAddon = CreateFrame("Frame", nil, scrollAddon)
    contentAddon:SetSize(CONTENT_WIDTH - 40, 10)
    scrollAddon:SetScrollChild(contentAddon)

    local logo = contentAddon:CreateTexture(nil, "ARTWORK")
    logo:SetSize(128, 128)
    logo:SetPoint("TOP", contentAddon, "TOP", 0, 0)
    logo:SetTexture("Interface\\AddOns\\iTank\\media\\itanklogo")

    local addonText = L["INFO_ADDON"] or ""
    local fsAddon = contentAddon:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fsAddon:SetWidth(CONTENT_WIDTH - 50)
    fsAddon:SetPoint("TOPLEFT", contentAddon, "TOPLEFT", 0, -148)
    fsAddon:SetJustifyH("LEFT")
    fsAddon:SetText(addonText)

    contentAddon:SetHeight(logo:GetHeight() + 20 + fsAddon:GetStringHeight() + 20)

    -- ========================================================================
    -- 5. 特别致谢 (Special Thanks)
    -- 类别：说明文档（致谢），可迁移至 Docs 或 templates
    -- ========================================================================
    local panelSpecialThanks = CreateContentPanel("SpecialThanks")

    local scrollSpecial = CreateFrame("ScrollFrame", nil, panelSpecialThanks, "UIPanelScrollFrameTemplate")
    scrollSpecial:SetPoint("TOPLEFT", panelSpecialThanks, "TOPLEFT", 10, -10)
    scrollSpecial:SetPoint("BOTTOMRIGHT", panelSpecialThanks, "BOTTOMRIGHT", -30, 10)

    local contentSpecial = CreateFrame("Frame", nil, scrollSpecial)
    contentSpecial:SetSize(CONTENT_WIDTH - 40, 10)
    scrollSpecial:SetScrollChild(contentSpecial)

    local specialText = L["INFO_SPECIAL_THANKS"] or ""
    local fsSpecial = contentSpecial:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fsSpecial:SetWidth(CONTENT_WIDTH - 50)
    fsSpecial:SetPoint("TOP", contentSpecial, "TOP", 0, 0)
    fsSpecial:SetJustifyH("CENTER")
    fsSpecial:SetText(specialText)

    contentSpecial:SetHeight(fsSpecial:GetStringHeight() + 20)

    -- ========================================================================
    -- 6. 关于我们 (About Us)
    -- 类别：说明文档（联系我们），可迁移至 Docs 或 templates
    -- ========================================================================
    local panelAboutUs = CreateContentPanel("AboutUs")

    local fsAbout = panelAboutUs:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fsAbout:SetPoint("TOPLEFT", panelAboutUs, "TOPLEFT", 20, -20)
    fsAbout:SetWidth(CONTENT_WIDTH - 40)
    fsAbout:SetJustifyH("CENTER")
    fsAbout:SetText(L["INFO_ABOUT_US"] or "iTank Studio Works\n\nUI&创意：ahhz\n编码：霜语、ahhz")

    local yOff = -20 - (fsAbout:GetStringHeight() or 0) - 10
    local _, fontSize = fsAbout:GetFont()
    if fontSize then yOff = yOff - fontSize * 1 end
    local iconSize = 32
    local gap = 10
    local totalWidth = iconSize * 5 + gap * 4
    local startX = (CONTENT_WIDTH - totalWidth) / 2
    local function PutTextToChatEdit(text)
        if ChatFrame_OpenChat then
            ChatFrame_OpenChat(text, DEFAULT_CHAT_FRAME)
            return
        end
        local eb = ChatEdit_ChooseBoxForSend and ChatEdit_ChooseBoxForSend(DEFAULT_CHAT_FRAME)
        if eb then
            ChatEdit_ActivateChat(eb)
            eb:SetText(text)
            eb:HighlightText()
            return
        end
        if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
            DEFAULT_CHAT_FRAME:AddMessage(text)
        end
    end
    local function SetTooltip(btn, text)
        btn:SetScript("OnEnter", function(self)
            if GameTooltip then
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:SetText(text)
            end
        end)
        btn:SetScript("OnLeave", function()
            if GameTooltip then GameTooltip:Hide() end
        end)
    end
    local icons = {
        { tex = "Interface\\AddOns\\iTank\\Media\\bilibili.png", url = "https://space.bilibili.com/294757892", tip = L["ABOUTUS_TOOLTIP_BILIBILI"] },
        { tex = "Interface\\AddOns\\iTank\\Media\\wclbox.png", url = "https://www.wclbox.com/games/1/StringItem/4399", tip = L["ABOUTUS_TOOLTIP_WCLBOX"] },
        { tex = "Interface\\AddOns\\iTank\\Media\\dd.png", url = "https://dd.163.com/room/311796", tip = L["ABOUTUS_TOOLTIP_DD"] },
        { tex = "Interface\\AddOns\\iTank\\Media\\afdian.jpg", url = "https://afdian.com/a/ahhz147344", tip = L["ABOUTUS_TOOLTIP_AFDIAN"] },
        { tex = "Interface\\AddOns\\iTank\\Media\\kdocs.png", url = "https://www.kdocs.cn/l/crBKZnyimQbH", tip = L["ABOUTUS_TOOLTIP_KDOCS"] },
    }
    local prev
    for i, item in ipairs(icons) do
        local btn = CreateFrame("Button", nil, panelAboutUs)
        btn:SetSize(iconSize, iconSize)
        if i == 1 then
            btn:SetPoint("TOPLEFT", panelAboutUs, "TOPLEFT", startX, yOff)
        else
            btn:SetPoint("LEFT", prev, "RIGHT", gap, 0)
        end
        btn:SetNormalTexture(item.tex)
        btn:SetScript("OnClick", function() PutTextToChatEdit(item.url) end)
        SetTooltip(btn, item.tip or "")
        prev = btn
    end

    -- ========================================================================
    -- 创建侧边栏按钮
    -- 类别：设置 UI - 导航
    -- ========================================================================
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

    -- 默认选中第一个
    btn1:GetScript("OnClick")(btn1)

    ITank.OptionsFrame = f
    return f
end

-- 发布到全局命名空间供其他模块使用
ITank.CreateOptionsFrame = CreateOptionsFrame

-- ============================================================================
-- 拆分注释（模块化准备）
-- 类别：引导/全局
-- 目标：入口 iTank.lua 保留初始化与装配；业务与版本差异下沉至 Data/templates
-- ============================================================================
local addonName, ns = ...
local L = ns.L or {}

ITank = ITank or {}
ns = ns or {}
ns.ITank = ITank

local ITANK_VERSION = "0.9.8"

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

-- 帮助窗口
-- 类别：UI 面板（帮助）
-- 拆分目标：templates/ui_*（Help 面板）
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

-- 主设置面板
-- 类别：设置 UI 总装配（包含侧边栏与多内容页）
-- 拆分目标：templates/ui_* 或 module/iTank_module.lua（装配层）
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
        versionText:SetText(string.format(L["VERSION_SHORT"], ITANK_VERSION) .. (label ~= "" and ("(" .. label .. ")") or ""))
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
    closeText:SetFont(GetButtonFont(), 14, GetFontFlags())
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
    -- 拆分目标：templates/ui_*（Settings.Interface）
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
    -- 拆分目标：templates/ui_*（Settings.Data）
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
        local function appendUnavailable(labelFS)
            local note = L["UNAVAILABLE_IN_VERSION"] or ""
            local cur = labelFS:GetText() or ""
            if note ~= "" and not string.find(cur, note, 1, true) then
                labelFS:SetText(cur .. note)
            end
        end
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

-- 角色面板下方主界面
-- 类别：主 UI 容器（Basic/DPS/Defense 三段）
-- 拆分目标：templates/ui_*（Panels.Basic / Panels.DPS / Panels.Defense）
local function CreateMainFrame()
    if ITank.MainFrame then return ITank.MainFrame end

    local parent = CharacterFrame or UIParent
    local f = CreateFrame("Frame", "ITankMainFrame", parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    f:SetSize(440, 210)
    if iTankDB.MainOffsetX == nil then iTankDB.MainOffsetX = 13 end
    if iTankDB.MainOffsetY == nil then iTankDB.MainOffsetY = 40 end
    local ox = iTankDB.MainOffsetX
    local oy = iTankDB.MainOffsetY
    f:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", ox, oy)
    f:SetFrameStrata("BACKGROUND")
    f:EnableMouse(false)
    f:EnableKeyboard(false)
    f:Show()

    local HEIGHT_BASIC = iTankDB.BasicHeight or 50
    local HEIGHT_DPS = iTankDB.DPSHeight or 50
    local HEIGHT_DEFENSE = iTankDB.DefenseHeight or 95
    local FRAME_WIDTH = 440
    
    -- 通用背景设置
    local backdropInfo = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true, tileSize = 16, edgeSize = 0,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

    -- 1. 创建子面板 (基础信息, DPS, 防御)
    local framesConfig = {
        { key = "BasicFrame",   height = HEIGHT_BASIC,   relativeTo = f,            point = "TOPLEFT",    rPoint = "TOPLEFT" },
        { key = "DPSFrame",     height = HEIGHT_DPS,     relativeTo = "BasicFrame", point = "TOPLEFT",    rPoint = "BOTTOMLEFT" },
        { key = "DefenseFrame", height = HEIGHT_DEFENSE, relativeTo = "DPSFrame",   point = "TOPLEFT",    rPoint = "BOTTOMLEFT" },
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
    
    -- 更新布局函数
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
        if defenseFrame:IsShown() then
            totalHeight = totalHeight + defenseFrame:GetHeight()
        end
        f:SetHeight(totalHeight)
        -- 同步背景图尺寸与位置（高度等于面板高度，保持方形纵横比；锚定右下角 0,0）
        if f.DefenseBgTex then
            local h = defenseFrame:GetHeight() or 95
            f.DefenseBgTex:ClearAllPoints()
            f.DefenseBgTex:SetPoint("BOTTOMRIGHT", defenseFrame, "BOTTOMRIGHT", 0, 0)
            f.DefenseBgTex:SetSize(h, h)
        end
    end
    f.UpdateLayout = UpdateLayout
    
    -- 防御面板右下角背景图片 (暂时禁用)
    --[[
    do
        local tex = defenseFrame:CreateTexture(nil, "BACKGROUND")
        tex:SetTexture("Interface\\AddOns\\iTank\\Media\\ilogo.tga")
        tex:SetAlpha(iTankDB.BackgroundAlpha or 0.9)
        tex:SetPoint("BOTTOMRIGHT", defenseFrame, "BOTTOMRIGHT", 0, 0)
        local h0 = defenseFrame:GetHeight() or 95
        tex:SetSize(h0, h0)
        f.DefenseBgTex = tex
    end
    ]]
    function f:UpdatePosition()
        local p = CharacterFrame or UIParent
        local x = iTankDB.MainOffsetX or 13
        local y = iTankDB.MainOffsetY or 40
        self:ClearAllPoints()
        self:SetPoint("TOPLEFT", p, "BOTTOMLEFT", x, y)
    end

    -- 应用显示设置逻辑
    f.ApplyVisibilitySettings = function(self)
        -- 防御面板逻辑
        if self.manualShowDefense ~= nil then
            if self.manualShowDefense then defenseFrame:Show() else defenseFrame:Hide() end
        else
            defenseFrame:Show()
        end
        -- DPS面板逻辑
        if self.manualShowDPS ~= nil then
            if self.manualShowDPS then dpsFrame:Show() else dpsFrame:Hide() end
        else
            dpsFrame:Show()
        end
        self:UpdateLayout()
    end

    -- 战斗冻结：战斗中禁止任何数据计算与刷新，脱战后再统一刷新一次。
    f.pendingFullRefresh = false
    f.IsDataFrozen = function(self)
        if type(InCombatLockdown) == "function" then
            local ok, locked = pcall(InCombatLockdown)
            if ok and locked then
                return true
            end
        end
        if type(UnitAffectingCombat) == "function" then
            return UnitAffectingCombat("player") and true or false
        end
        return false
    end
    f.QueuePostCombatRefresh = function(self)
        self.pendingFullRefresh = true
    end

    -- 更新 DPS 面板函数
    f.UpdateDPSInfo = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end
        if not dpsFrame:IsShown() then return end
        
        -- 从 Data 模块获取数据
        local lines = ITank.Data:GetDPSPanelText()
        
        -- 设置文本
        self.DPSLine1:SetText(lines.line1)
        self.DPSLine2:SetText(lines.line2)
        self.DPSLine3:SetText(lines.line3)
        
        -- 应用文字颜色
        if self.UpdateTextColor then self:UpdateTextColor() end
    end

    -- 绑定 DPS 面板显示事件
    dpsFrame:SetScript("OnShow", function() f:UpdateDPSInfo() end)
    
    -- 1. 帮助按钮 (?) - 最右侧
    local btnHelp = CreateToggleButton(basicFrame, L["BUTTON_HELP"] or "?", function()
        local f = ITank.HelpFrame or CreateHelpFrame()
        if f:IsShown() then
            f:Hide()
        else
            f:Show()
            if ITank.OptionsFrame and ITank.OptionsFrame:IsShown() then
                ITank.OptionsFrame:Hide()
            end
        end
    end, L["TOOLTIP_HELP"])
    f.BtnHelp = btnHelp
    -- 绝对定位: TOPRIGHT, x=0, y=0 (与主界面右上角重合)
    btnHelp:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -25, 0)

    -- 2. 设置按钮 (S)
    local btnSet = CreateToggleButton(basicFrame, L["BUTTON_SETTINGS"] or "S", function()
        local f = ITank.OptionsFrame or CreateOptionsFrame()
        if f:IsShown() then
            f:Hide()
        else
            f:Show()
            local helpFrame = ITank.HelpFrame or CreateHelpFrame()
            if helpFrame and helpFrame:IsShown() then
                helpFrame:Hide()
            end
        end
    end, L["TOOLTIP_SETTINGS"])
    f.BtnSet = btnSet
    -- 绝对定位: TOPRIGHT, x=-25 (-24 - 1)
    btnSet:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -50, 0)

    -- 3. 防御按钮 (T)
    local btnDef = CreateToggleButton(basicFrame, L["BUTTON_DEFENSE"] or "T", function()
        if defenseFrame:IsShown() then
            defenseFrame:Hide()
            f.manualShowDefense = false
            iTankDB.ShowDefense = false
        else
            defenseFrame:Show()
            f.manualShowDefense = true
            iTankDB.ShowDefense = true
        end
        UpdateLayout()
    end, L["TOOLTIP_DEFENSE"])
    f.BtnDef = btnDef
    -- 绝对定位: TOPRIGHT, x=-50 (-25 - 24 - 1)
    btnDef:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -75, 0)

    -- 3.5 特别版按钮 (SE)
    do
        local btnSE = CreateFrame("Button", nil, basicFrame, BackdropTemplateMixin and "BackdropTemplate" or nil)
        btnSE:SetSize(24, 24)
        btnSE:SetFrameStrata("HIGH")
        btnSE:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            tile = true, tileSize = 24, edgeSize = 0,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        })
        btnSE:SetBackdropColor(0, 0, 0, iTankDB.BackgroundAlpha or 0.9)
        local tx = btnSE:CreateTexture(nil, "ARTWORK")
        tx:SetAllPoints()
        local seInfo = GetSEInfo()
        local texPath = iTankDB.SEIconPath or (seInfo and seInfo.iconPath)
        if texPath and texPath ~= "" then
            tx:SetTexture(texPath)
        end
        btnSE:EnableMouse(true)
        btnSE:SetScript("OnEnter", function(self)
            self:SetBackdropColor(0.3, 0.3, 0.3, iTankDB.BackgroundAlpha or 0.9)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            local loc = GetLocale()
            local seInfo = GetSEInfo()
            if seInfo and seInfo.text then
                local t = seInfo.text[loc] or seInfo.text.enUS
                if t and t.title then
                    GameTooltip:AddLine(t.title, 1.0, 0.41, 0.71, true)
                    if t.body and t.body ~= "" then
                        GameTooltip:AddLine(t.body, 1, 1, 1, true)
                    end
                end
            end
            GameTooltip:Show()
        end)
        btnSE:SetScript("OnLeave", function(self)
            self:SetBackdropColor(0, 0, 0, iTankDB.BackgroundAlpha or 0.9)
            GameTooltip:Hide()
        end)
        btnSE:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", 0, 0)
        f.BtnSE = btnSE
    end

    -- 4. DPS按钮 (D)
    local btnDPS = CreateToggleButton(basicFrame, L["BUTTON_DPS"] or "D", function()
        if dpsFrame:IsShown() then
            dpsFrame:Hide()
            f.manualShowDPS = false
            iTankDB.ShowDPS = false
        else
            dpsFrame:Show()
            f.manualShowDPS = true
            iTankDB.ShowDPS = true
            -- f:UpdateDPSInfo() -- 由 OnShow 处理
        end
        UpdateLayout()
    end, L["TOOLTIP_DPS"])
    f.BtnDPS = btnDPS
    -- 绝对定位: TOPRIGHT, x=-100 (-75 - 24 - 1)，因插入 SE 按钮后整体左移一格
    btnDPS:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -100, 0)

    local currentFontSize = iTankDB.FontSize or 14

    -- 创建 DPS 面板内容
    local dpsLines = { "DPSLine1", "DPSLine2", "DPSLine3" }
    for _, key in ipairs(dpsLines) do
        local fs = dpsFrame:CreateFontString(nil, "OVERLAY")
        fs:SetFont(GetButtonFont(), currentFontSize, GetFontFlags())
        fs:SetJustifyH("LEFT")
        fs:SetTextColor(1, 0.75, 0.75)
        f[key] = fs
    end
    local dpsLine1, dpsLine2, dpsLine3 = f.DPSLine1, f.DPSLine2, f.DPSLine3

    -- 垂直居中
    dpsLine2:SetPoint("LEFT", dpsFrame, "LEFT", 10, 0)
    dpsLine1:SetPoint("BOTTOMLEFT", dpsLine2, "TOPLEFT", 0, 0)
    dpsLine3:SetPoint("TOPLEFT", dpsLine2, "BOTTOMLEFT", 0, 0)

    -- 创建防御面板内容
    local defenseLayout = {
        { key = "DefCol1", anchor = {"LEFT", defenseFrame, "LEFT", 10, 0} },
        { key = "DefCol2", anchor = {"TOPLEFT", "DefCol1", "TOPLEFT", 120, 0} },
        { key = "DefCol3", anchor = {"TOPLEFT", "DefCol1", "TOPLEFT", 270, 0} },
    }

    for _, item in ipairs(defenseLayout) do
        local fs = defenseFrame:CreateFontString(nil, "OVERLAY")
        fs:SetFont(GetButtonFont(), currentFontSize, GetFontFlags())
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        fs:SetTextColor(1, 0.75, 0.75)
        
        local p, rel, rp, x, y = unpack(item.anchor)
        if type(rel) == "string" then rel = f[rel] end
        fs:SetPoint(p, rel, rp, x, y)
        
        f[item.key] = fs
    end

    f.UpdateDefenseInfo = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end
        if not defenseFrame:IsShown() then return end
        
        -- 从Data模块获取文本
        local texts = ITank.Data:GetDefensePanelText()
        
        self.DefCol1:SetText(texts.col1)
        self.DefCol2:SetText(texts.col2)
        self.DefCol3:SetText(texts.col3)
        
        -- 应用文字颜色
        if self.UpdateTextColor then self:UpdateTextColor() end
    end

    f.UpdateBackdropColor = function(self)
        local a = iTankDB.BackgroundAlpha or 0.9
        local r, g, b = 0, 0, 0
        if type(iTankDB.BackgroundRGB) == "table" then
            r = iTankDB.BackgroundRGB[1] or 0
            g = iTankDB.BackgroundRGB[2] or 0
            b = iTankDB.BackgroundRGB[3] or 0
        end
        local frames = { "BasicFrame", "DPSFrame", "DefenseFrame" }
        local function ensureFlatBg(frame)
            if not frame or not frame.SetBackdrop then return end
            frame:SetBackdrop({
                bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
                tile = true, tileSize = 16, edgeSize = 0,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
        end
        for _, k in ipairs(frames) do
            if self[k] then
                ensureFlatBg(self[k])
                if self[k].SetBackdropColor then self[k]:SetBackdropColor(r, g, b, a) end
            end
        end
        if self.DefenseBgTex then self.DefenseBgTex:SetAlpha(a) end
    end

    f.UpdateTextColor = function(self)
        local r, g, b = 1, 1, 1
        if type(iTankDB.TextRGB) == "table" then
            r = iTankDB.TextRGB[1] or 1
            g = iTankDB.TextRGB[2] or 1
            b = iTankDB.TextRGB[3] or 1
        end
        -- 更新DPS面板文字颜色
        if self.DPSLine1 then self.DPSLine1:SetTextColor(r, g, b) end
        if self.DPSLine2 then self.DPSLine2:SetTextColor(r, g, b) end
        if self.DPSLine3 then self.DPSLine3:SetTextColor(r, g, b) end
        -- 更新防御面板文字颜色
        if self.DefCol1 then self.DefCol1:SetTextColor(r, g, b) end
        if self.DefCol2 then self.DefCol2:SetTextColor(r, g, b) end
        if self.DefCol3 then self.DefCol3:SetTextColor(r, g, b) end
    end

    -- Restore manual show states from SavedVariables
    if iTankDB.ShowDefense ~= nil then
        f.manualShowDefense = iTankDB.ShowDefense and true or false
    end
    if iTankDB.ShowDPS ~= nil then
        f.manualShowDPS = iTankDB.ShowDPS and true or false
    end
    if f.ApplyVisibilitySettings then f:ApplyVisibilitySettings() end
    if f.UpdateBackdropColor then f:UpdateBackdropColor() end
    if f.UpdateTextColor then f:UpdateTextColor() end

    f.UpdateFontSize = function(self)
        local size = iTankDB.FontSize or 14
        local font = GetButtonFont()
        local texts = {
             "DPSLine1", "DPSLine2", "DPSLine3",
             "DefCol1", "DefCol2", "DefCol3",
             "BasicInfoLine1_1", "BasicInfoLine1_2",
             "BasicInfoLine2_1", "BasicInfoLine2_2", "BasicInfoLine2_3",
             "BasicInfoLine3_1", "BasicInfoLine3_2", "BasicInfoLine3_3", "BasicInfoLine3_4"
        }
        for _, k in ipairs(texts) do
            if self[k] then self[k]:SetFont(font, size, GetFontFlags()) end
        end
    end

    -- 创建 BasicInfo 面板内容
    local basicLayout = {
        -- 根节点
        { key = "BasicInfoLine2_1", anchor = {"LEFT", basicFrame, "LEFT", 10, 0} },
        { key = "BasicInfoLine2_2", anchor = {"LEFT", basicFrame, "LEFT", 130, 0} },
        
        -- 第一层
        { key = "BasicInfoLine1_1", anchor = {"BOTTOMLEFT", "BasicInfoLine2_1", "TOPLEFT", 0, 0}, color = {1, 0.75, 0.75} },
        { key = "BasicInfoLine1_2", anchor = {"BOTTOMLEFT", "BasicInfoLine2_2", "TOPLEFT", 0, 0}, color = {1, 0.75, 0.75} },
        { key = "BasicInfoLine3_1", anchor = {"TOPLEFT", "BasicInfoLine2_1", "BOTTOMLEFT", 0, 0} },
        { key = "BasicInfoLine3_2", anchor = {"TOPLEFT", "BasicInfoLine2_2", "BOTTOMLEFT", 0, 0} },
        { key = "BasicInfoLine2_3", anchor = {"TOPLEFT", "BasicInfoLine2_1", "TOPLEFT", 210, 0} },
        
        -- 第二层
        { key = "BasicInfoLine3_3", anchor = {"TOPLEFT", "BasicInfoLine3_1", "TOPLEFT", 210, 0} },
        { key = "BasicInfoLine3_4", anchor = {"TOPLEFT", "BasicInfoLine3_1", "TOPLEFT", 320, 0} },
    }

    for _, item in ipairs(basicLayout) do
        local fs = basicFrame:CreateFontString(nil, "OVERLAY")
        fs:SetFont(GetButtonFont(), currentFontSize, GetFontFlags())
        fs:SetJustifyH("LEFT")
        if item.color then
            fs:SetTextColor(unpack(item.color))
        end
        
        local p, rel, rp, x, y = unpack(item.anchor)
        if type(rel) == "string" then rel = f[rel] end
        fs:SetPoint(p, rel, rp, x, y)
        
        f[item.key] = fs
    end
    
    -- 更新函数
    f.UpdateBasicInfo = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end
        -- 从 Data 模块获取数据
        local info = ITank.Data:GetBasicInfo()
        local r, g, b = unpack(info.classColor)
        
        -- 第一行
        local label = ""
        if ITank and ITank.Data and ITank.Data.GetGameVersionLabel then
            label = ITank.Data:GetGameVersionLabel() or ""
        end
        local ver = string.format(L["ITANK_VERSION_FMT"], ITANK_VERSION) .. (label ~= "" and ("(" .. label .. ")") or "")
        self.BasicInfoLine1_1:SetText(ver)
        self.BasicInfoLine1_2:SetText(string.format(L["BASIC_REALM"], info.realm))
        
        -- 第二行
        self.BasicInfoLine2_1:SetText(string.format(L["BASIC_NAME"], info.name))
        self.BasicInfoLine2_1:SetTextColor(r, g, b)
        
        self.BasicInfoLine2_2:SetText(string.format(L["BASIC_CLASS"], info.className))
        self.BasicInfoLine2_2:SetTextColor(r, g, b)
        
        if ITank and ITank.Data and ITank.Data.IsMOP then
            self.BasicInfoLine2_3:SetText(string.format(L["SPEC_FMT"], info.talentInfo))
        else
            self.BasicInfoLine2_3:SetText(string.format(L["BASIC_TALENT"], info.talentInfo))
        end
        self.BasicInfoLine2_3:SetTextColor(r, g, b)
        
        -- 第三行
        self.BasicInfoLine3_1:SetText(string.format(L["BASIC_RACE"], info.race))
        self.BasicInfoLine3_1:SetTextColor(r, g, b)
        
        self.BasicInfoLine3_2:SetText(string.format(L["BASIC_LEVEL"], info.level))
        self.BasicInfoLine3_2:SetTextColor(r, g, b)
        
        self.BasicInfoLine3_3:SetText(string.format(L["BASIC_HP"], info.hp))
        self.BasicInfoLine3_3:SetTextColor(r, g, b)

        self.BasicInfoLine3_4:SetText(string.format(L["BASIC_POWER"], info.power))
        self.BasicInfoLine3_4:SetTextColor(r, g, b)
    end

    f.RefreshAllData = function(self, force)
        if (not force) and self.IsDataFrozen and self:IsDataFrozen() then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end
        self.pendingFullRefresh = false
        self:UpdateBasicInfo(true)
        self:UpdateDPSInfo(true)
        self:UpdateDefenseInfo(true)
    end
    
    f:RefreshAllData()
    
    -- 注册事件以更新信息
    f:RegisterEvent("UNIT_HEALTH")
    f:RegisterEvent("UNIT_MAXHEALTH")
    f:RegisterEvent("UNIT_POWER_UPDATE")
    f:RegisterEvent("UNIT_MAXPOWER")
    f:RegisterEvent("PLAYER_LEVEL_UP")
    f:RegisterEvent("CHARACTER_POINTS_CHANGED")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    -- 保留 UNIT_INVENTORY_CHANGED，用于装备变化时更新DPS/防御面板
    f:RegisterEvent("UNIT_INVENTORY_CHANGED")
    f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    f:RegisterEvent("PLAYER_TALENT_UPDATE")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    -- 添加用于 DPS/属性更新的事件（已注释，避免高频）
    -- f:RegisterEvent("UNIT_AURA")
    -- f:RegisterEvent("UNIT_STATS")
    -- f:RegisterEvent("UNIT_ATTACK_POWER")
    -- f:RegisterEvent("UNIT_RANGED_ATTACK_POWER")
    f:RegisterEvent("COMBAT_RATING_UPDATE")

    f:SetScript("OnEvent", function(self, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end
        if event == "PLAYER_REGEN_ENABLED" then
            if self.pendingFullRefresh and self.RefreshAllData then
                self:RefreshAllData(true)
            end
            return
        end
        if self.IsDataFrozen and self:IsDataFrozen() then
            if self.QueuePostCombatRefresh then self:QueuePostCombatRefresh() end
            return
        end

        local unit = ...
        local isUnitEvent = (event == "UNIT_AURA" or 
                             event == "UNIT_STATS" or event == "UNIT_ATTACK_POWER" or 
                             event == "UNIT_RANGED_ATTACK_POWER" or event == "UNIT_HEALTH" or 
                             event == "UNIT_MAXHEALTH" or event == "UNIT_POWER_UPDATE" or 
                             event == "UNIT_MAXPOWER")
        
        if isUnitEvent then
            if unit == "player" then
                self:UpdateBasicInfo()
                -- 移除频繁的DPS和防御更新，只在装备/天赋变化时更新
                -- self:UpdateDPSInfo()
                -- self:UpdateDefenseInfo()
            end
        elseif event == "UNIT_INVENTORY_CHANGED" then
            if unit == "player" then
                if ITank.Data and ITank.Data.InvalidateSetCache then
                    ITank.Data:InvalidateSetCache()
                end
                self:UpdateDPSInfo()
                self:UpdateDefenseInfo()
            end
        else
            -- 全局事件 (PLAYER_LEVEL_UP, COMBAT_RATING_UPDATE 等)
            self:UpdateBasicInfo()
            self:UpdateDPSInfo()
            self:UpdateDefenseInfo()
            if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
                if self.ApplyVisibilitySettings then self:ApplyVisibilitySettings() end
            end
        end
    end)
    
    -- 确保初始化时更新一次所有信息（战斗中仅打标记，脱战后补一次）
    f:RefreshAllData()
    
    -- 同步初始布局高度
    UpdateLayout()
    
    -- 绑定显示事件以自动刷新
    defenseFrame:SetScript("OnShow", function() f:UpdateDefenseInfo() end)

    ITank.MainFrame = f
    return f
end

-- 绑定角色面板显示/隐藏
local function HookCharacterFrame()
    if ITank.CharacterHooked then return end

    local function EnsureMainFrameParent()
        if not CharacterFrame then return end
        local main = ITank.MainFrame or CreateMainFrame()
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
    local f = ITank.OptionsFrame or CreateOptionsFrame()
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

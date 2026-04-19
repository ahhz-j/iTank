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
    local btnHelp = ITank.CreateToggleButton(basicFrame, L["BUTTON_HELP"] or "?", function()
        local hf = ITank.HelpFrame or ITank.CreateHelpFrame()
        if hf:IsShown() then
            hf:Hide()
        else
            hf:Show()
            if ITank.OptionsFrame and ITank.OptionsFrame:IsShown() then
                ITank.OptionsFrame:Hide()
            end
        end
    end, L["TOOLTIP_HELP"])
    f.BtnHelp = btnHelp
    -- 绝对定位: TOPRIGHT, x=0, y=0 (与主界面右上角重合)
    btnHelp:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -25, 0)

    -- 2. 设置按钮 (S)
    local btnSet = ITank.CreateToggleButton(basicFrame, L["BUTTON_SETTINGS"] or "S", function()
        local sf = ITank.OptionsFrame or ITank.CreateOptionsFrame()
        if sf:IsShown() then
            sf:Hide()
        else
            sf:Show()
            local helpFrame = ITank.HelpFrame or ITank.CreateHelpFrame()
            if helpFrame and helpFrame:IsShown() then
                helpFrame:Hide()
            end
        end
    end, L["TOOLTIP_SETTINGS"])
    f.BtnSet = btnSet
    -- 绝对定位: TOPRIGHT, x=-25 (-24 - 1)
    btnSet:SetPoint("TOPRIGHT", basicFrame, "TOPRIGHT", -50, 0)

    -- 3. 防御按钮 (T)
    local btnDef = ITank.CreateToggleButton(basicFrame, L["BUTTON_DEFENSE"] or "T", function()
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
        local seInfo = ITank.GetSEInfo()
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
            local seInfo = ITank.GetSEInfo()
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
    local btnDPS = ITank.CreateToggleButton(basicFrame, L["BUTTON_DPS"] or "D", function()
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
        fs:SetFont(ITank.GetButtonFont(), currentFontSize, ITank.GetFontFlags())
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
        local font = ITank.GetButtonFont()
        local texts = {
             "DPSLine1", "DPSLine2", "DPSLine3",
             "DefCol1", "DefCol2", "DefCol3",
             "BasicInfoLine1_1", "BasicInfoLine1_2",
             "BasicInfoLine2_1", "BasicInfoLine2_2", "BasicInfoLine2_3",
             "BasicInfoLine3_1", "BasicInfoLine3_2", "BasicInfoLine3_3", "BasicInfoLine3_4"
        }
        for _, k in ipairs(texts) do
            if self[k] then self[k]:SetFont(font, size, ITank.GetFontFlags()) end
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
        fs:SetFont(ITank.GetButtonFont(), currentFontSize, ITank.GetFontFlags())
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
        local ver = string.format(L["ITANK_VERSION_FMT"], ITank.VERSION) .. (label ~= "" and ("(" .. label .. ")") or "")
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

-- 发布到全局命名空间供其他模块使用
ITank.CreateMainFrame = CreateMainFrame

------------------------------------------------------------
-- PvP Toggle Turtle (Turtle-WoW-kompatibel)
-- Features:
--  - Frame mit Icon + Status + Timer
--  - Farbwechsel: Grün (inaktiv), Rot (aktiv), Gelb (Deaktivierung)
--  - 5-Minuten-Timer beim PvP-Deaktivieren (eigene Logik)
--  - Skalierung (Slider im Options-Fenster + Slash-Befehl)
--  - Lock/Unlock Drag + kleines Icon
--  - Minimap-Button (Links: Optionen, Rechts: Frame ein/aus)
--  - Framebreite passt sich Text + Timer + Icon an
--  - Lock/Unlock-Button im Optionsfenster
--  - Optionaler Hinweis bei Timer-Reset (PvP-Kontakt)
--  - Debug-Modus
------------------------------------------------------------

PvpToggleTurtleDB = PvpToggleTurtleDB or {}

------------------------------------------------------------
-- Lokalisierung
------------------------------------------------------------

local LOCALE = GetLocale and GetLocale() or "enUS"
if LOCALE == "enGB" then LOCALE = "enUS" end

local L = {}
local function AddLocale(loc, entries) L[loc] = entries end

AddLocale("enUS", {
    PREFIX = "[PvP Toggle]",

    ADDON_LOADED = "Addon loaded.",
    PVP_ENABLED  = "PvP enabled.",
    PVP_DEACTIVATING_STARTED = "PvP is being disabled. 5-minute countdown started.",
    PVP_DEACTIVATING_CANCELED = "PvP deactivation canceled. PvP remains active.",

    LOCKED_MSG = "Frame position locked (lock icon shown).",
    UNLOCKED_MSG = "Frame position unlocked (lock icon hidden).",

    TIMER_RESET_NOTICE = "PvP combat detected – deactivation timer reset to 5:00.",

    DEBUG_ENABLED = "Debug enabled.",
    DEBUG_DISABLED = "Debug disabled.",
})

AddLocale("deDE", {
    PREFIX = "[PvP Toggle]",

    ADDON_LOADED = "Addon geladen.",
    PVP_ENABLED  = "PvP aktiviert.",
    PVP_DEACTIVATING_STARTED = "PvP wird deaktiviert. 5-Minuten-Countdown gestartet.",
    PVP_DEACTIVATING_CANCELED = "PvP-Deaktivierung abgebrochen. PvP bleibt aktiv.",

    LOCKED_MSG = "Frame-Position gesperrt (Schloss sichtbar).",
    UNLOCKED_MSG = "Frame-Position freigegeben (Schloss ausgeblendet).",

    TIMER_RESET_NOTICE = "PvP-Kontakt erkannt – Deaktivierungs-Timer auf 5:00 zurückgesetzt.",

    DEBUG_ENABLED = "Debug-Modus aktiviert.",
    DEBUG_DISABLED = "Debug-Modus deaktiviert.",
})

-- Fallback for other locales
AddLocale("frFR", L["enUS"])
AddLocale("esES", L["enUS"])
AddLocale("esMX", L["enUS"])
AddLocale("ptBR", L["enUS"])
AddLocale("itIT", L["enUS"])
AddLocale("ruRU", L["enUS"])
AddLocale("koKR", L["enUS"])
AddLocale("zhCN", L["enUS"])
AddLocale("zhTW", L["enUS"])

local function T(key)
    local tbl = L[LOCALE] or L["enUS"]
    return (tbl and tbl[key]) or (L["enUS"] and L["enUS"][key]) or key
end

------------------------------------------------------------
-- Chat output helpers
------------------------------------------------------------

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PvP Toggle]|r " .. (msg or ""))
end

local function Debug(msg)
    if PvpToggleTurtleDB and PvpToggleTurtleDB.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[PvP Toggle]|r |cffaaaaaa[Debug]|r " .. (msg or ""))
    end
end

------------------------------------------------------------
-- Utility
------------------------------------------------------------

local function IsPVPOn()
    return UnitIsPVP("player")
end

local function SecondsToTimeString(sec)
    if not sec or sec <= 0 then return "" end
    local minutes = math.floor(sec / 60)
    local seconds = math.mod(sec, 60)
    return string.format("%d:%02d", minutes, seconds)
end

------------------------------------------------------------
-- Globals
------------------------------------------------------------

local mainFrame, statusText, countdownText, swordTexture, minimapButton, lockIndicator
local optionsFrame, optionsScaleSlider, optionsScaleValueText, optionsLockButton
local optionsResetNoticeButton, optionsDebugButton

local deactivationEndTime
local DEACTIVATION_DURATION = 5 * 60

------------------------------------------------------------
-- Defaults & DB
------------------------------------------------------------

local DEFAULTS = {
    scale           = 1.0,
    lock            = false,
    showFrame       = true,
    showResetNotice = false,
    debug           = false,
    framePoint      = nil,
    frameRelPoint   = nil,
    frameX          = nil,
    frameY          = nil,
}

local function SetDefaultsInto(tbl)
    if tbl.scale == nil            then tbl.scale            = DEFAULTS.scale end
    if tbl.lock == nil             then tbl.lock             = DEFAULTS.lock end
    if tbl.showFrame == nil        then tbl.showFrame        = DEFAULTS.showFrame end
    if tbl.showResetNotice == nil  then tbl.showResetNotice  = DEFAULTS.showResetNotice end
    if tbl.debug == nil            then tbl.debug            = DEFAULTS.debug end
    if tbl.framePoint == nil       then tbl.framePoint       = DEFAULTS.framePoint end
    if tbl.frameRelPoint == nil    then tbl.frameRelPoint    = DEFAULTS.frameRelPoint end
    if tbl.frameX == nil           then tbl.frameX           = DEFAULTS.frameX end
    if tbl.frameY == nil           then tbl.frameY           = DEFAULTS.frameY end
end

local function EnsureDefaults()
    if not PvpToggleTurtleDB or type(PvpToggleTurtleDB) ~= "table" then
        PvpToggleTurtleDB = {}
    end
    SetDefaultsInto(PvpToggleTurtleDB)
end

------------------------------------------------------------
-- UI state updates
------------------------------------------------------------

local function UpdateResetNoticeButton()
    if not optionsResetNoticeButton then return end
    if PvpToggleTurtleDB.showResetNotice then
        optionsResetNoticeButton:SetText("Reset notice: ON")
    else
        optionsResetNoticeButton:SetText("Reset notice: OFF")
    end
end

local function UpdateDebugButton()
    if not optionsDebugButton then return end
    if PvpToggleTurtleDB.debug then
        optionsDebugButton:SetText("Debug: ON")
    else
        optionsDebugButton:SetText("Debug: OFF")
    end
end

local function UpdateLockIndicator()
    if lockIndicator then
        if PvpToggleTurtleDB.lock then lockIndicator:Show() else lockIndicator:Hide() end
    end

    if optionsLockButton then
        if PvpToggleTurtleDB.lock then
            optionsLockButton:SetText("Entsperren")
        else
            optionsLockButton:SetText("Sperren")
        end
    end
end

local function UpdateFrameWidth()
    if not mainFrame or not statusText or not countdownText then return end

    local statusWidth    = statusText:GetStringWidth() or 0
    local countdownWidth = countdownText:GetStringWidth() or 0

    local iconWidth            = 20
    local paddingLeft          = 8
    local paddingRight         = 8
    local gapIconToStatus      = 6
    local gapStatusToCountdown = 6
    if countdownWidth <= 0 then gapStatusToCountdown = 0 end

    local totalWidth = paddingLeft
        + iconWidth
        + gapIconToStatus
        + statusWidth
        + gapStatusToCountdown
        + countdownWidth
        + paddingRight

    totalWidth = totalWidth + 16 -- lock icon area

    if totalWidth < 90 then totalWidth = 90 end
    mainFrame:SetWidth(totalWidth)
end

------------------------------------------------------------
-- Position save/restore
------------------------------------------------------------

local function SaveFramePosition()
    if not mainFrame then return end
    local point, _, relPoint, xOfs, yOfs = mainFrame:GetPoint(1)
    PvpToggleTurtleDB.framePoint    = point
    PvpToggleTurtleDB.frameRelPoint = relPoint
    PvpToggleTurtleDB.frameX        = xOfs
    PvpToggleTurtleDB.frameY        = yOfs
    Debug(string.format("Saved position: %s %s (%.1f, %.1f)", tostring(point), tostring(relPoint), tonumber(xOfs) or 0, tonumber(yOfs) or 0))
end

local function RestoreFramePosition()
    if not mainFrame then return end
    if PvpToggleTurtleDB.framePoint then
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint(
            PvpToggleTurtleDB.framePoint,
            UIParent,
            PvpToggleTurtleDB.frameRelPoint or PvpToggleTurtleDB.framePoint,
            PvpToggleTurtleDB.frameX or 0,
            PvpToggleTurtleDB.frameY or 0
        )
        Debug("Restored saved position.")
    else
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        Debug("No saved position found; using CENTER.")
    end
end

------------------------------------------------------------
-- PvP toggle + timer
------------------------------------------------------------

local function DoTogglePVPCommand()
    if TogglePVP then
        TogglePVP()
    else
        RunMacroText("/pvp")
    end
end

local function TogglePvP()
    local now   = GetTime()
    local pvpOn = IsPVPOn()

    Debug("TogglePvP called. pvpOn=" .. tostring(pvpOn) .. " deactivationEndTime=" .. tostring(deactivationEndTime))

    if pvpOn and not deactivationEndTime then
        deactivationEndTime = now + DEACTIVATION_DURATION
        Print(T("PVP_DEACTIVATING_STARTED"))
        Debug("Started deactivation timer: " .. tostring(DEACTIVATION_DURATION) .. " sec")
        DoTogglePVPCommand()

    elseif pvpOn and deactivationEndTime then
        deactivationEndTime = nil
        Print(T("PVP_DEACTIVATING_CANCELED"))
        Debug("Canceled deactivation timer.")
        DoTogglePVPCommand()

    else
        deactivationEndTime = nil
        Print(T("PVP_ENABLED"))
        Debug("Enabled PvP (no timer).")
        DoTogglePVPCommand()
    end
end

------------------------------------------------------------
-- Status refresh (including WoW-style timer reset)
------------------------------------------------------------

local function RefreshStatus()
    if not mainFrame or not statusText or not countdownText or not swordTexture then return end

    local now   = GetTime()
    local pvpOn = IsPVPOn()

    if deactivationEndTime and pvpOn then
        local remainingFloat = deactivationEndTime - now
        if remainingFloat < (DEACTIVATION_DURATION - 1) then
            deactivationEndTime = now + DEACTIVATION_DURATION
            Debug("Detected PvP timer reset by combat; resetting internal timer.")
            if PvpToggleTurtleDB.showResetNotice then
                Print(T("TIMER_RESET_NOTICE"))
            end
        end
    end

    local r, g, b
    local text = ""
    local timerText = ""

    if deactivationEndTime then
        local remaining = math.floor(deactivationEndTime - now)
        if remaining > 0 then
            text = "|cffffff00PvP: Deaktivierung|r"
            timerText = SecondsToTimeString(remaining)
            r, g, b = 1, 1, 0
        else
            deactivationEndTime = nil
            Debug("Deactivation timer finished; clearing internal timer.")
        end
    end

    if not deactivationEndTime then
        if pvpOn then
            text = "|cffff0000PvP: Aktiv|r"
            r, g, b = 1, 0, 0
            timerText = ""
        else
            text = "|cff00ff00PvP: Inaktiv|r"
            r, g, b = 0, 1, 0
            timerText = ""
        end
    end

    statusText:SetText(text)
    countdownText:SetText(timerText or "")

    swordTexture:SetVertexColor(r or 1, g or 1, b or 1)

    UpdateFrameWidth()
end

------------------------------------------------------------
-- Options window
------------------------------------------------------------

local function OpenOptionsFrame()
    if not optionsFrame then
        local f = CreateFrame("Frame", "PvPToggleTurtle_OptionsFrame", UIParent)
        optionsFrame = f

        f:SetWidth(260)
        f:SetHeight(245)
        f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        f:SetFrameStrata("DIALOG")

        f:SetBackdrop({
            bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = 1, tileSize = 8,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)

        f:SetMovable(true)
        f:EnableMouse(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function() this:StartMoving() end)
        f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)

        local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", 0, -10)
        title:SetText("PvP Toggle - Optionen")

        local slider = CreateFrame("Slider", "PvPToggleTurtle_ScaleSlider", f, "OptionsSliderTemplate")
        optionsScaleSlider = slider
        slider:SetWidth(200)
        slider:SetHeight(16)
        slider:SetPoint("TOP", 0, -50)
        slider:SetMinMaxValues(0.5, 2.0)
        slider:SetValueStep(0.05)

        getglobal(slider:GetName() .. "Low"):SetText("0.5")
        getglobal(slider:GetName() .. "High"):SetText("2.0")
        getglobal(slider:GetName() .. "Text"):SetText("Skalierung")

        local valueText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        optionsScaleValueText = valueText
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, -4)
        valueText:SetText(string.format("Aktuell: %.2f", 1.00))

        slider:SetScript("OnValueChanged", function()
            local val = this:GetValue()
            val = math.floor(val * 100 + 0.5) / 100

            if mainFrame then mainFrame:SetScale(val) end
            PvpToggleTurtleDB.scale = val

            if optionsScaleValueText then
                optionsScaleValueText:SetText(string.format("Aktuell: %.2f", val))
            end

            Debug("Scale changed to " .. tostring(val))
        end)

        local lockBtn = CreateFrame("Button", "PvPToggleTurtle_LockButton", f, "UIPanelButtonTemplate")
        optionsLockButton = lockBtn
        lockBtn:SetWidth(100)
        lockBtn:SetHeight(22)
        lockBtn:SetPoint("TOP", valueText, "BOTTOM", 0, -28)
        lockBtn:SetText("Sperren")

        lockBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.lock = not PvpToggleTurtleDB.lock
            UpdateLockIndicator()
            if PvpToggleTurtleDB.lock then
                Print(T("LOCKED_MSG"))
                Debug("Frame locked via options.")
            else
                Print(T("UNLOCKED_MSG"))
                Debug("Frame unlocked via options.")
            end
        end)

        local resetBtn = CreateFrame("Button", "PvPToggleTurtle_ResetNoticeButton", f, "UIPanelButtonTemplate")
        optionsResetNoticeButton = resetBtn
        resetBtn:SetWidth(180)
        resetBtn:SetHeight(22)
        resetBtn:SetPoint("TOP", lockBtn, "BOTTOM", 0, -10)
        resetBtn:SetText("Reset notice: OFF")

        resetBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.showResetNotice = not PvpToggleTurtleDB.showResetNotice
            UpdateResetNoticeButton()
            Debug("showResetNotice set to " .. tostring(PvpToggleTurtleDB.showResetNotice))
        end)

        local dbgBtn = CreateFrame("Button", "PvPToggleTurtle_DebugButton", f, "UIPanelButtonTemplate")
        optionsDebugButton = dbgBtn
        dbgBtn:SetWidth(120)
        dbgBtn:SetHeight(22)
        dbgBtn:SetPoint("TOP", resetBtn, "BOTTOM", 0, -10)
        dbgBtn:SetText("Debug: OFF")

        dbgBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.debug = not PvpToggleTurtleDB.debug
            UpdateDebugButton()
            if PvpToggleTurtleDB.debug then
                Print(T("DEBUG_ENABLED"))
            else
                Print(T("DEBUG_DISABLED"))
            end
        end)

        local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        close:SetWidth(80)
        close:SetHeight(22)
        close:SetPoint("BOTTOM", 0, 10)
        close:SetText("Schließen")
        close:SetScript("OnClick", function() optionsFrame:Hide() end)
    end

    local currentScale = PvpToggleTurtleDB.scale or 1.0
    if optionsScaleSlider then optionsScaleSlider:SetValue(currentScale) end
    if optionsScaleValueText then optionsScaleValueText:SetText(string.format("Aktuell: %.2f", currentScale)) end

    UpdateLockIndicator()
    UpdateResetNoticeButton()
    UpdateDebugButton()
    optionsFrame:Show()
end

------------------------------------------------------------
-- Main frame creation
------------------------------------------------------------

local function CreateMainFrame()
    if mainFrame then return end

    local f = CreateFrame("Frame", "PvPToggleTurtle_MainFrame", UIParent)
    mainFrame = f

    f:SetWidth(130)
    f:SetHeight(26)

    f:SetBackdrop({
        bgFile   = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = 1, tileSize = 8,
        edgeSize = 12,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    f:SetBackdropColor(0, 0, 0, 0.80)

    f:EnableMouse(1)
    f:SetMovable(1)
    f:RegisterForDrag("LeftButton")

    f:SetScript("OnDragStart", function()
        if not PvpToggleTurtleDB.lock then
            this:StartMoving()
        else
            Debug("Drag blocked (frame is locked).")
        end
    end)
    f:SetScript("OnDragStop", function()
        this:StopMovingOrSizing()
        SaveFramePosition()
    end)

    lockIndicator = f:CreateTexture("PvPToggleTurtle_LockIcon", "OVERLAY")
    lockIndicator:SetWidth(12)
    lockIndicator:SetHeight(12)
    lockIndicator:SetPoint("TOPRIGHT", f, "TOPRIGHT", -3, -3)
    lockIndicator:SetTexture("Interface\\AddOns\\PVPToggleTurtleWOW\\Icons\\Lock")
    lockIndicator:Hide()

    local swordButton = CreateFrame("Button", nil, f)
    swordButton:SetWidth(20)
    swordButton:SetHeight(20)
    swordButton:SetPoint("LEFT", 6, 0)

    local tex = swordButton:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\Icons\\INV_Sword_27")
    swordTexture = tex

    swordButton:SetScript("OnClick", function()
        Debug("Sword clicked.")
        TogglePvP()
        RefreshStatus()
    end)

    statusText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    statusText:SetPoint("LEFT", swordButton, "RIGHT", 6, 0)
    statusText:SetText("")

    countdownText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    countdownText:SetPoint("RIGHT", f, "RIGHT", -24, 0)
    countdownText:SetText("")

    f.timeSinceLastUpdate = 0
    f:SetScript("OnUpdate", function()
        local elapsed = arg1 or 0
        this.timeSinceLastUpdate = (this.timeSinceLastUpdate or 0) + elapsed
        if this.timeSinceLastUpdate < 0.5 then return end
        this.timeSinceLastUpdate = 0
        RefreshStatus()
    end)

    RestoreFramePosition()
    f:SetScale(PvpToggleTurtleDB.scale or 1.0)
    UpdateLockIndicator()
    RefreshStatus()

    if PvpToggleTurtleDB.showFrame then f:Show() else f:Hide() end
end

------------------------------------------------------------
-- Minimap button
------------------------------------------------------------

local function CreateMinimapButton()
    if minimapButton or not Minimap then return end

    local b = CreateFrame("Button", "PvPToggleTurtle_MinimapButton", Minimap)
    minimapButton = b

    b:SetWidth(31)
    b:SetHeight(31)
    b:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

    local icon = b:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\INV_Sword_27")
    icon:SetWidth(20)
    icon:SetHeight(20)
    icon:SetPoint("CENTER", 0, 0)
    b.icon = icon

    b:SetNormalTexture("Interface\\Minimap\\UI-Minimap-Background")
    b:SetPushedTexture("Interface\\Minimap\\UI-Minimap-Background")
    b:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- CHANGED: Right click now toggles the frame visibility (NOT PvP)
    b:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            OpenOptionsFrame()
        else
            if mainFrame then
                if mainFrame:IsShown() then
                    mainFrame:Hide()
                    PvpToggleTurtleDB.showFrame = false
                    Print("Frame versteckt.")
                else
                    mainFrame:Show()
                    PvpToggleTurtleDB.showFrame = true
                    RefreshStatus()
                    Print("Frame angezeigt.")
                end
            end
        end
    end)

    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText("PvP Toggle", 1,1,1)
        GameTooltip:AddLine("Linksklick: Optionen", 1,1,1)
        GameTooltip:AddLine("Rechtsklick: Frame ein/aus", 0.8,0.8,0.8)
        GameTooltip:Show()
    end)

    b:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

------------------------------------------------------------
-- Events
------------------------------------------------------------

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")

eventFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        EnsureDefaults()
        CreateMainFrame()
        CreateMinimapButton()
        RefreshStatus()
        Print(T("ADDON_LOADED"))
    elseif event == "PLAYER_FLAGS_CHANGED" then
        RefreshStatus()
    end
end)

------------------------------------------------------------
-- Slash commands
------------------------------------------------------------

SLASH_PVPTTG1 = "/pvptoggle"
SlashCmdList["PVPTTG"] = function(msg)
    msg = string.lower(msg or "")
    msg = string.gsub(msg, "^%s+", "")
    msg = string.gsub(msg, "%s+$", "")

    if msg == "" or msg == "help" then
        Print("Befehle:")
        Print(" /pvptoggle              : PvP an/aus")
        Print(" /pvptoggle show         : Frame anzeigen")
        Print(" /pvptoggle hide         : Frame verstecken")
        Print(" /pvptoggle lock         : Frame-Position sperren (Icon an)")
        Print(" /pvptoggle unlock       : Frame-Position freigeben (Icon aus)")
        Print(" /pvptoggle scale <0.5-2>: Skalierung setzen")
        Print(" /pvptoggle config       : Options-Fenster öffnen")
        Print(" /pvptoggle debug [on/off]: Debug-Modus umschalten")
        return
    end

    if msg == "show" then
        if mainFrame then mainFrame:Show() end
        PvpToggleTurtleDB.showFrame = true
        Print("Frame angezeigt.")

    elseif msg == "hide" then
        if mainFrame then mainFrame:Hide() end
        PvpToggleTurtleDB.showFrame = false
        Print("Frame versteckt.")

    elseif msg == "lock" then
        PvpToggleTurtleDB.lock = true
        UpdateLockIndicator()
        Print(T("LOCKED_MSG"))

    elseif msg == "unlock" then
        PvpToggleTurtleDB.lock = false
        UpdateLockIndicator()
        Print(T("UNLOCKED_MSG"))

    elseif string.find(msg, "^scale") == 1 then
        local num = tonumber(string.match(msg, "scale%s+([%d%.]+)"))
        if not num then
            Print("Bitte eine Zahl angeben, z.B.: /pvptoggle scale 1.2")
            return
        end
        if num < 0.5 then num = 0.5 end
        if num > 2.0 then num = 2.0 end
        PvpToggleTurtleDB.scale = num
        if mainFrame then mainFrame:SetScale(num) end
        Print(string.format("Skalierung auf %.2f gesetzt.", num))

    elseif msg == "config" then
        OpenOptionsFrame()

    elseif string.find(msg, "^debug") == 1 then
        local arg = string.match(msg, "^debug%s+(%S+)$")
        if arg == "on" then
            PvpToggleTurtleDB.debug = true
        elseif arg == "off" then
            PvpToggleTurtleDB.debug = false
        else
            PvpToggleTurtleDB.debug = not PvpToggleTurtleDB.debug
        end

        UpdateDebugButton()

        if PvpToggleTurtleDB.debug then
            Print(T("DEBUG_ENABLED"))
        else
            Print(T("DEBUG_DISABLED"))
        end

    else
        TogglePvP()
        RefreshStatus()
    end
end

------------------------------------------------------------
-- PvP Toggle Turtle (Turtle WoW compatible)
-- Author: Fragglechen
------------------------------------------------------------

PvpToggleTurtleDB = PvpToggleTurtleDB or {}

------------------------------------------------------------
-- Localization
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

    PVP_FORCED_BG = "You are in a battleground. PvP is forced here (toggle disabled).",

    STATUS_PVP_ACTIVE = "PvP: Active",
    STATUS_PVP_INACTIVE = "PvP: Inactive",
    STATUS_PVP_DEACTIVATING = "PvP: Disabling",

    FRAME_SHOWN = "Frame shown.",
    FRAME_HIDDEN = "Frame hidden.",

    MINIMAP_TOOLTIP_TITLE = "PvP Toggle",
    MINIMAP_TOOLTIP_LEFT  = "Left Click: Options",
    MINIMAP_TOOLTIP_RIGHT = "Right Click: Show/Hide frame",

    OPTIONS_TITLE = "PvP Toggle - Options",
    OPTIONS_SCALE = "Scale",
    OPTIONS_CURRENT = "Current: %.2f",
    OPTIONS_CLOSE = "Close",
    OPTIONS_LOCK = "Lock",
    OPTIONS_UNLOCK = "Unlock",

    OPTIONS_RESETNOTICE_LABEL = "Reset notice",
    OPTIONS_SOUND_LABEL = "Reset sound",
    OPTIONS_COOLDOWN_LABEL = "Notice cooldown",
    OPTIONS_COOLDOWN_CURRENT = "Cooldown: %ds",

    OPTIONS_DEBUG_LABEL = "Debug",
    OPTIONS_ON = "ON",
    OPTIONS_OFF = "OFF",

    HELP_TITLE = "Commands:",
    HELP_TOGGLE = " /pvptoggle               : Toggle PvP",
    HELP_SHOW   = " /pvptoggle show          : Show frame",
    HELP_HIDE   = " /pvptoggle hide          : Hide frame",
    HELP_LOCK   = " /pvptoggle lock          : Lock frame position",
    HELP_UNLOCK = " /pvptoggle unlock        : Unlock frame position",
    HELP_SCALE  = " /pvptoggle scale <0.5-2> : Set scale",
    HELP_CONFIG = " /pvptoggle config        : Open options",
    HELP_DEBUG  = " /pvptoggle debug [on/off]: Toggle debug mode",
    ERR_SCALE_NUMBER = "Please enter a number, e.g.: /pvptoggle scale 1.2",
    SCALE_SET = "Scale set to %.2f.",
})

AddLocale("deDE", {
    PREFIX = "[PvP Toggle]",

    ADDON_LOADED = "Addon geladen.",
    PVP_ENABLED  = "PvP aktiviert.",
    PVP_DEACTIVATING_STARTED = "PvP wird deaktiviert. 5-Minuten-Countdown gestartet.",
    PVP_DEACTIVATING_CANCELED = "PvP-Deaktivierung abgebrochen. PvP bleibt aktiv.",

    LOCKED_MSG = "Frame-Position gesperrt (Schloss sichtbar).",
    UNLOCKED_MSG = "Frame-Position freigegeben (Schloss ausgeblendet).",

    TIMER_RESET_NOTICE = "PvP-Kampf erkannt – Deaktivierungs-Timer auf 5:00 zurückgesetzt.",

    DEBUG_ENABLED = "Debug-Modus aktiviert.",
    DEBUG_DISABLED = "Debug-Modus deaktiviert.",

    PVP_FORCED_BG = "Du bist in einem Schlachtfeld. PvP ist hier erzwungen (Toggle deaktiviert).",

    STATUS_PVP_ACTIVE = "PvP: Aktiv",
    STATUS_PVP_INACTIVE = "PvP: Inaktiv",
    STATUS_PVP_DEACTIVATING = "PvP: Deaktivierung",

    FRAME_SHOWN = "Frame angezeigt.",
    FRAME_HIDDEN = "Frame versteckt.",

    MINIMAP_TOOLTIP_TITLE = "PvP Toggle",
    MINIMAP_TOOLTIP_LEFT  = "Linksklick: Optionen",
    MINIMAP_TOOLTIP_RIGHT = "Rechtsklick: Frame ein/aus",

    OPTIONS_TITLE = "PvP Toggle - Optionen",
    OPTIONS_SCALE = "Skalierung",
    OPTIONS_CURRENT = "Aktuell: %.2f",
    OPTIONS_CLOSE = "Schließen",
    OPTIONS_LOCK = "Sperren",
    OPTIONS_UNLOCK = "Entsperren",

    OPTIONS_RESETNOTICE_LABEL = "Reset-Hinweis",
    OPTIONS_SOUND_LABEL = "Reset-Sound",
    OPTIONS_COOLDOWN_LABEL = "Cooldown Reset-Hinweis",
    OPTIONS_COOLDOWN_CURRENT = "Cooldown: %ds",

    OPTIONS_DEBUG_LABEL = "Debug",
    OPTIONS_ON = "AN",
    OPTIONS_OFF = "AUS",

    HELP_TITLE = "Befehle:",
    HELP_TOGGLE = " /pvptoggle               : PvP an/aus",
    HELP_SHOW   = " /pvptoggle show          : Frame anzeigen",
    HELP_HIDE   = " /pvptoggle hide          : Frame verstecken",
    HELP_LOCK   = " /pvptoggle lock          : Frame sperren",
    HELP_UNLOCK = " /pvptoggle unlock        : Frame entsperren",
    HELP_SCALE  = " /pvptoggle scale <0.5-2> : Skalierung setzen",
    HELP_CONFIG = " /pvptoggle config        : Optionen öffnen",
    HELP_DEBUG  = " /pvptoggle debug [on/off]: Debug-Modus umschalten",
    ERR_SCALE_NUMBER = "Bitte eine Zahl angeben, z.B.: /pvptoggle scale 1.2",
    SCALE_SET = "Skalierung auf %.2f gesetzt.",
})

-- Fallback locales (English)
AddLocale("frFR", L["enUS"])
AddLocale("esES", L["enUS"])
AddLocale("esMX", L["enUS"])
AddLocale("ruRU", L["enUS"])
AddLocale("koKR", L["enUS"])
AddLocale("zhCN", L["enUS"])
AddLocale("zhTW", L["enUS"])
AddLocale("ptBR", L["enUS"])
AddLocale("itIT", L["enUS"])

local function T(key)
    local tbl = L[LOCALE] or L["enUS"]
    return (tbl and tbl[key]) or (L["enUS"] and L["enUS"][key]) or key
end

------------------------------------------------------------
-- Chat output helpers
------------------------------------------------------------

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. T("PREFIX") .. "|r " .. (msg or ""))
end

local function Debug(msg)
    if PvpToggleTurtleDB and PvpToggleTurtleDB.debug then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00" .. T("PREFIX") .. "|r |cffaaaaaa[Debug]|r " .. (msg or ""))
    end
end

------------------------------------------------------------
-- Screen message + sound helpers
------------------------------------------------------------

local function ShowScreenErrorMessage(msg)
    if not msg or msg == "" then return end
    if UIErrorsFrame and UIErrorsFrame.AddMessage then
        UIErrorsFrame:AddMessage(msg, 1.0, 0.1, 0.1, 1.0)
    end
end

local function PlayResetSound()
    if not PvpToggleTurtleDB.resetSound then return end
    if not PlaySound then return end
    pcall(PlaySound, "igQuestListComplete")
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

local function IsInBattleground()
    if not IsInInstance then return false end
    local inInstance, instanceType = IsInInstance()
    return inInstance and instanceType == "pvp"
end

------------------------------------------------------------
-- Combat log text filtering
-- Do NOT reset on cast-start messages.
-- Incoming: must affect player.
-- Outgoing: must be player as source ("You ...", "Ihr ...").
------------------------------------------------------------

local function _tolower(s)
    if not s then return "" end
    return string.lower(s)
end

local CAST_START_PHRASES = {
    enUS = { "begins to cast", "begins to perform" },
    deDE = { "beginnt zu wirken", "beginnt zu zaubern", "beginnt" },
    frFR = { "commence" },
    esES = { "empieza a" },
    esMX = { "empieza a" },
    ruRU = { "начинает" },
    koKR = { "시전" },
    zhCN = { "开始" },
    zhTW = { "開始" },
}

local function IsCastStartMessage(msg)
    local m = _tolower(msg)
    local list = CAST_START_PHRASES[LOCALE] or CAST_START_PHRASES["enUS"]
    for _, p in ipairs(list) do
        if p ~= "" and string.find(m, _tolower(p), 1, true) then
            return true
        end
    end
    if string.find(m, "begins to cast", 1, true) or string.find(m, "begins to perform", 1, true) then
        return true
    end
    return false
end

local function MessageMentionsPlayerAsTarget(msg)
    if not msg then return false end

    local name = UnitName("player")
    if name and name ~= "" and string.find(msg, name, 1, true) then
        return true
    end

    local m = _tolower(msg)
    if string.find(m, "you", 1, true) then return true end
    if LOCALE == "deDE" and (string.find(m, "dich", 1, true) or string.find(m, "euch", 1, true) or string.find(m, "dir", 1, true)) then
        return true
    end

    return false
end

local function MessageLooksLikeResult(msg)
    local m = _tolower(msg)
    if string.find(m, "hit", 1, true) then return true end
    if string.find(m, "hits", 1, true) then return true end
    if string.find(m, "crit", 1, true) then return true end
    if string.find(m, "damage", 1, true) then return true end
    if string.find(m, "heals", 1, true) then return true end
    if string.find(m, "healed", 1, true) then return true end
    if LOCALE == "deDE" and (string.find(m, "trifft", 1, true) or string.find(m, "schaden", 1, true) or string.find(m, "heilt", 1, true)) then
        return true
    end
    return false
end

-- Detect that the player is the source (outgoing)
local function IsPlayerOutgoingMessage(msg)
    if not msg or msg == "" then return false end
    local m = _tolower(msg)

    -- English
    if string.find(m, "you ", 1, true) == 1 then return true end
    if string.find(m, "your ", 1, true) == 1 then return true end

    -- German common
    if LOCALE == "deDE" then
        if string.find(m, "ihr ", 1, true) == 1 then return true end
        if string.find(m, "euer ", 1, true) == 1 then return true end
        if string.find(m, "eure ", 1, true) == 1 then return true end
        if string.find(m, "dein ", 1, true) == 1 then return true end
        if string.find(m, "deine ", 1, true) == 1 then return true end
        if string.find(m, "du ", 1, true) == 1 then return true end
    end

    return false
end

local function ShouldResetIncoming(msg)
    if not msg or msg == "" then return false end
    if IsCastStartMessage(msg) then return false end
    if not MessageLooksLikeResult(msg) then return false end
    if not MessageMentionsPlayerAsTarget(msg) then return false end
    return true
end

local function ShouldResetOutgoing(msg)
    if not msg or msg == "" then return false end
    if IsCastStartMessage(msg) then return false end
    if not MessageLooksLikeResult(msg) then return false end
    if not IsPlayerOutgoingMessage(msg) then return false end
    return true
end

------------------------------------------------------------
-- Globals
------------------------------------------------------------

local mainFrame, statusText, countdownText, swordTexture, minimapButton, lockIndicator
local optionsFrame, optionsScaleSlider, optionsScaleValueText, optionsLockButton
local optionsResetNoticeButton, optionsSoundButton
local optionsCooldownLabel, optionsCooldownSlider, optionsCooldownValueText
local optionsDebugButton

local deactivationEndTime
local lastPvPTimerMS = nil -- for reset detection via GetPVPTimer()
local deactivationRequested = false
local DEACTIVATION_DURATION = 5 * 60

local lastResetAnnounceTime = 0

------------------------------------------------------------
-- Defaults & DB
------------------------------------------------------------

local DEFAULTS = {
    scale              = 1.0,
    lock               = false,
    showFrame          = true,

    resetNoticeEnabled = true,  -- chat + screen together
    resetSound         = false,
    screenNoticeCD     = 5,     -- seconds

    debug              = false,

    framePoint         = nil,
    frameRelPoint      = nil,
    frameX             = nil,
    frameY             = nil,
}

local function SetDefaultsInto(tbl)
    for k, v in pairs(DEFAULTS) do
        if tbl[k] == nil then tbl[k] = v end
    end
end

local function EnsureDefaults()
    if not PvpToggleTurtleDB or type(PvpToggleTurtleDB) ~= "table" then
        PvpToggleTurtleDB = {}
    end

    SetDefaultsInto(PvpToggleTurtleDB)

    -- Migration from old separate options (if present)
    if PvpToggleTurtleDB.showResetNotice ~= nil or PvpToggleTurtleDB.showScreenNotice ~= nil then
        PvpToggleTurtleDB.resetNoticeEnabled =
            (PvpToggleTurtleDB.showResetNotice == true) or (PvpToggleTurtleDB.showScreenNotice == true)

        PvpToggleTurtleDB.showResetNotice = nil
        PvpToggleTurtleDB.showScreenNotice = nil
    end

    if tonumber(PvpToggleTurtleDB.screenNoticeCD) == nil then
        PvpToggleTurtleDB.screenNoticeCD = 5
    end
    if PvpToggleTurtleDB.screenNoticeCD < 0 then PvpToggleTurtleDB.screenNoticeCD = 0 end
    if PvpToggleTurtleDB.screenNoticeCD > 30 then PvpToggleTurtleDB.screenNoticeCD = 30 end
end

------------------------------------------------------------
-- Timer reset helper
-- IMPORTANT: timer reset is ALWAYS instant
-- Cooldown applies ONLY to notifications.
------------------------------------------------------------

local function ResetDeactivationTimer(reason)
    if not deactivationRequested then return end
    if not IsPVPOn() then return end

    local now = GetTime()

    -- Always reset immediately
    deactivationEndTime = now + DEACTIVATION_DURATION
    Debug("ResetDeactivationTimer (instant): " .. tostring(reason or "unknown"))

    -- Notices disabled -> stop (timer reset already happened)
    if not PvpToggleTurtleDB.resetNoticeEnabled then
        return
    end

    -- Cooldown only for notice output
    local cd = tonumber(PvpToggleTurtleDB.screenNoticeCD) or 5
    if cd < 0 then cd = 0 end

    if (now - (lastResetAnnounceTime or 0)) < cd then
        return
    end

    lastResetAnnounceTime = now

    ShowScreenErrorMessage(T("TIMER_RESET_NOTICE"))
    Print(T("TIMER_RESET_NOTICE"))
    PlayResetSound()
end

------------------------------------------------------------
-- UI state updates
------------------------------------------------------------

local function UpdateSoundButton()
    if not optionsSoundButton then return end
    local state = PvpToggleTurtleDB.resetSound and T("OPTIONS_ON") or T("OPTIONS_OFF")
    optionsSoundButton:SetText(T("OPTIONS_SOUND_LABEL") .. ": " .. state)
end

local function UpdateCooldownUI()
    if not optionsCooldownSlider or not optionsCooldownValueText then return end
    local cd = tonumber(PvpToggleTurtleDB.screenNoticeCD) or 5
    cd = math.floor(cd + 0.5)
    if cd < 0 then cd = 0 end
    if cd > 30 then cd = 30 end
    optionsCooldownValueText:SetText(string.format(T("OPTIONS_COOLDOWN_CURRENT"), cd))
end

local function UpdateResetNoticeButton()
    if not optionsResetNoticeButton then return end

    local enabled = (PvpToggleTurtleDB.resetNoticeEnabled == true)
    local state = enabled and T("OPTIONS_ON") or T("OPTIONS_OFF")
    optionsResetNoticeButton:SetText(T("OPTIONS_RESETNOTICE_LABEL") .. ": " .. state)

    -- Show/hide sound option depending on reset notice enabled
    if optionsSoundButton then
        if enabled then optionsSoundButton:Show() else optionsSoundButton:Hide() end

    -- Show/hide cooldown controls when Reset-Hinweis is enabled
    if optionsCooldownLabel then
        if enabled then optionsCooldownLabel:Show() else optionsCooldownLabel:Hide() end
    end
    if optionsCooldownSlider then
        if enabled then optionsCooldownSlider:Show() else optionsCooldownSlider:Hide() end
    end
    if optionsCooldownValueText then
        if enabled then optionsCooldownValueText:Show() else optionsCooldownValueText:Hide() end
    end

    -- Reduce empty space in options frame
    if optionsFrame then
        if enabled then
            optionsFrame:SetHeight(340)
        else
            optionsFrame:SetHeight(280)
        end
    end
    end

    -- Re-anchor cooldown section so it doesn't leave a visual gap
    if optionsCooldownLabel and optionsCooldownSlider then
        optionsCooldownLabel:ClearAllPoints()

        if enabled and optionsSoundButton and optionsSoundButton:IsShown() then
            optionsCooldownLabel:SetPoint("TOP", optionsSoundButton, "BOTTOM", 0, -18)
        else
            optionsCooldownLabel:SetPoint("TOP", optionsResetNoticeButton, "BOTTOM", 0, -18)
        end

        optionsCooldownSlider:ClearAllPoints()
        optionsCooldownSlider:SetPoint("TOP", optionsCooldownLabel, "BOTTOM", 0, -12)
    end

    -- Cooldown slider active only if reset notice is enabled
    if optionsCooldownSlider then
        if enabled then
            optionsCooldownSlider:EnableMouse(true)
            optionsCooldownSlider:SetAlpha(1.0)
            if optionsCooldownValueText then optionsCooldownValueText:SetAlpha(1.0) end
        else
            optionsCooldownSlider:EnableMouse(false)
            optionsCooldownSlider:SetAlpha(0.4)
            if optionsCooldownValueText then optionsCooldownValueText:SetAlpha(0.4) end
        end
    end
end

local function UpdateDebugButton()
    if not optionsDebugButton then return end
    local state = PvpToggleTurtleDB.debug and T("OPTIONS_ON") or T("OPTIONS_OFF")
    optionsDebugButton:SetText(T("OPTIONS_DEBUG_LABEL") .. ": " .. state)
end

local function UpdateLockIndicator()
    if lockIndicator then
        if PvpToggleTurtleDB.lock then lockIndicator:Show() else lockIndicator:Hide() end
    end

    if optionsLockButton then
        if PvpToggleTurtleDB.lock then
            optionsLockButton:SetText(T("OPTIONS_UNLOCK"))
        else
            optionsLockButton:SetText(T("OPTIONS_LOCK"))
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
    else
        mainFrame:ClearAllPoints()
        mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

------------------------------------------------------------
-- PvP toggle
------------------------------------------------------------

local function DoTogglePVPCommand()
    if TogglePVP then
        TogglePVP()
    else
        RunMacroText("/pvp")
    end
end

local function TogglePvP()
    if IsInBattleground() then
        deactivationRequested = false
        deactivationEndTime = nil
        Print(T("PVP_FORCED_BG"))
        return
    end

    local now   = GetTime()
    local pvpOn = IsPVPOn()

    if pvpOn and not deactivationRequested then
        deactivationRequested = true
        deactivationEndTime = now + DEACTIVATION_DURATION
        Print(T("PVP_DEACTIVATING_STARTED"))
        DoTogglePVPCommand()
        return
    end

    if pvpOn and deactivationRequested then
        deactivationRequested = false
        deactivationEndTime = nil
        Print(T("PVP_DEACTIVATING_CANCELED"))
        DoTogglePVPCommand()
        return
    end

    deactivationRequested = false
    deactivationEndTime = nil
    Print(T("PVP_ENABLED"))
    DoTogglePVPCommand()
end

------------------------------------------------------------
-- Status refresh
------------------------------------------------------------

local function RefreshStatus()
    if not mainFrame or not statusText or not countdownText or not swordTexture then return end

    local now   = GetTime()
    local pvpOn = IsPVPOn()

    local r, g, b
    local text = ""
    local timerText = ""

    if deactivationRequested and pvpOn then
        local remaining = 0

        if GetPVPTimer then
            local ms = GetPVPTimer()
            -- Detect timer reset: if PvP deactivation timer jumps UP (>= 1000ms)
            if ms and ms > 0 and deactivationRequested and pvpOn then
                if lastPvPTimerMS and (ms - lastPvPTimerMS) >= 1000 then
                    ResetDeactivationTimer("pvptimer_jump")
                end
                lastPvPTimerMS = ms
            else
                lastPvPTimerMS = ms
            end
            if ms and ms > 0 then
                remaining = math.floor(ms / 1000)
            else
                if deactivationEndTime then
                    remaining = math.floor(deactivationEndTime - now)
                end
            end
        else
            if deactivationEndTime then
                remaining = math.floor(deactivationEndTime - now)
            end
        end

        if remaining and remaining > 0 then
            text = "|cffffff00" .. T("STATUS_PVP_DEACTIVATING") .. "|r"
            timerText = SecondsToTimeString(remaining)
            r, g, b = 1, 1, 0
        else
            deactivationRequested = false
            deactivationEndTime = nil
        end
    end

    if not (deactivationRequested and pvpOn) then
        if pvpOn then
            text = "|cffff0000" .. T("STATUS_PVP_ACTIVE") .. "|r"
            r, g, b = 1, 0, 0
            timerText = ""
        else
            text = "|cff00ff00" .. T("STATUS_PVP_INACTIVE") .. "|r"
            r, g, b = 0, 1, 0
            timerText = ""
            deactivationRequested = false
            deactivationEndTime = nil
        end
    end

    statusText:SetText(text)
    countdownText:SetText(timerText or "")
    swordTexture:SetVertexColor(r or 1, g or 1, b or 1)

        if (not deactivationRequested) or (not pvpOn) then
        lastPvPTimerMS = nil
    end

    UpdateFrameWidth()
end

------------------------------------------------------------
-- Options window
------------------------------------------------------------

local function OpenOptionsFrame()
    if not optionsFrame then
        local f = CreateFrame("Frame", "PvPToggleTurtle_OptionsFrame", UIParent)
        optionsFrame = f

        f:SetWidth(300)
        f:SetHeight(380)
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
        title:SetPoint("TOP", 0, -12)
        title:SetText(T("OPTIONS_TITLE"))

        local W_MAIN = 260
        local H_BTN  = 24
        local GAP    = 10

        local slider = CreateFrame("Slider", "PvPToggleTurtle_ScaleSlider", f, "OptionsSliderTemplate")
        optionsScaleSlider = slider
        slider:SetWidth(240)
        slider:SetHeight(16)
        slider:SetPoint("TOP", 0, -60)
        slider:SetMinMaxValues(0.5, 2.0)
        slider:SetValueStep(0.05)

        getglobal(slider:GetName() .. "Low"):SetText("0.5")
        getglobal(slider:GetName() .. "High"):SetText("2.0")
        getglobal(slider:GetName() .. "Text"):SetText(T("OPTIONS_SCALE"))

        local valueText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        optionsScaleValueText = valueText
        valueText:SetPoint("TOP", slider, "BOTTOM", 0, -6)
        valueText:SetText(string.format(T("OPTIONS_CURRENT"), 1.00))

        slider:SetScript("OnValueChanged", function()
            local val = this:GetValue()
            val = math.floor(val * 100 + 0.5) / 100
            if mainFrame then mainFrame:SetScale(val) end
            PvpToggleTurtleDB.scale = val
            if optionsScaleValueText then
                optionsScaleValueText:SetText(string.format(T("OPTIONS_CURRENT"), val))
            end
        end)

        local lockBtn = CreateFrame("Button", "PvPToggleTurtle_LockButton", f, "UIPanelButtonTemplate")
        optionsLockButton = lockBtn
        lockBtn:SetWidth(W_MAIN)
        lockBtn:SetHeight(H_BTN)
        lockBtn:SetPoint("TOP", valueText, "BOTTOM", 0, -18)
        lockBtn:SetText(T("OPTIONS_LOCK"))
        lockBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.lock = not PvpToggleTurtleDB.lock
            UpdateLockIndicator()
            if PvpToggleTurtleDB.lock then Print(T("LOCKED_MSG")) else Print(T("UNLOCKED_MSG")) end
        end)

        local resetBtn = CreateFrame("Button", "PvPToggleTurtle_ResetNoticeButton", f, "UIPanelButtonTemplate")
        optionsResetNoticeButton = resetBtn
        resetBtn:SetWidth(W_MAIN)
        resetBtn:SetHeight(H_BTN)
        resetBtn:SetPoint("TOP", lockBtn, "BOTTOM", 0, -GAP)
        resetBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.resetNoticeEnabled = not PvpToggleTurtleDB.resetNoticeEnabled
            UpdateResetNoticeButton()
        end)

        local soundBtn = CreateFrame("Button", "PvPToggleTurtle_SoundButton", f, "UIPanelButtonTemplate")
        optionsSoundButton = soundBtn
        soundBtn:SetWidth(W_MAIN)
        soundBtn:SetHeight(H_BTN)
        soundBtn:SetPoint("TOP", resetBtn, "BOTTOM", 0, -GAP)
        soundBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.resetSound = not PvpToggleTurtleDB.resetSound
            UpdateSoundButton()
        end)

        local cdLabel = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        optionsCooldownLabel = cdLabel
        cdLabel:SetPoint("TOP", soundBtn, "BOTTOM", 0, -18)
        cdLabel:SetText(T("OPTIONS_COOLDOWN_LABEL"))

        local cdSlider = CreateFrame("Slider", "PvPToggleTurtle_CooldownSlider", f, "OptionsSliderTemplate")
        optionsCooldownSlider = cdSlider
        cdSlider:SetWidth(240)
        cdSlider:SetHeight(16)
        cdSlider:SetPoint("TOP", cdLabel, "BOTTOM", 0, -12)
        cdSlider:SetMinMaxValues(0, 30)
        cdSlider:SetValueStep(1)

        getglobal(cdSlider:GetName() .. "Low"):SetText("0")
        getglobal(cdSlider:GetName() .. "High"):SetText("30")
        getglobal(cdSlider:GetName() .. "Text"):SetText("")

        local cdValue = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        optionsCooldownValueText = cdValue
        cdValue:SetPoint("TOP", cdSlider, "BOTTOM", 0, -6)
        cdValue:SetText("")

        cdSlider:SetScript("OnValueChanged", function()
            local v = math.floor((this:GetValue() or 0) + 0.5)
            if v < 0 then v = 0 end
            if v > 30 then v = 30 end
            PvpToggleTurtleDB.screenNoticeCD = v
            UpdateCooldownUI()
        end)

        local BOTTOM_W = 120

        local dbgBtn = CreateFrame("Button", "PvPToggleTurtle_DebugButton", f, "UIPanelButtonTemplate")
        optionsDebugButton = dbgBtn
        dbgBtn:SetWidth(BOTTOM_W)
        dbgBtn:SetHeight(H_BTN)
        dbgBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 18, 14)
        dbgBtn:SetScript("OnClick", function()
            PvpToggleTurtleDB.debug = not PvpToggleTurtleDB.debug
            UpdateDebugButton()
            if PvpToggleTurtleDB.debug then Print(T("DEBUG_ENABLED")) else Print(T("DEBUG_DISABLED")) end
        end)

        local close = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        close:SetWidth(BOTTOM_W)
        close:SetHeight(H_BTN)
        close:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -18, 14)
        close:SetText(T("OPTIONS_CLOSE"))
        close:SetScript("OnClick", function() optionsFrame:Hide() end)
    end

    local currentScale = PvpToggleTurtleDB.scale or 1.0
    if optionsScaleSlider then optionsScaleSlider:SetValue(currentScale) end
    if optionsScaleValueText then optionsScaleValueText:SetText(string.format(T("OPTIONS_CURRENT"), currentScale)) end

    if optionsCooldownSlider then
        local cd = tonumber(PvpToggleTurtleDB.screenNoticeCD) or 5
        if cd < 0 then cd = 0 end
        if cd > 30 then cd = 30 end
        optionsCooldownSlider:SetValue(cd)
    end

    UpdateLockIndicator()
    UpdateResetNoticeButton()
    UpdateSoundButton()
    UpdateCooldownUI()
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

    b:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            OpenOptionsFrame()
        else
            if mainFrame then
                if mainFrame:IsShown() then
                    mainFrame:Hide()
                    PvpToggleTurtleDB.showFrame = false
                    Print(T("FRAME_HIDDEN"))
                else
                    mainFrame:Show()
                    PvpToggleTurtleDB.showFrame = true
                    RefreshStatus()
                    Print(T("FRAME_SHOWN"))
                end
            end
        end
    end)

    b:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:SetText(T("MINIMAP_TOOLTIP_TITLE"), 1, 1, 1)
        GameTooltip:AddLine(T("MINIMAP_TOOLTIP_LEFT"), 1, 1, 1)
        GameTooltip:AddLine(T("MINIMAP_TOOLTIP_RIGHT"), 0.8, 0.8, 0.8)
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
eventFrame:RegisterEvent("UNIT_COMBAT")

-- Incoming hostile damage (to player)
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS")
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_MISSES")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_HOSTILEPLAYER_NODAMAGE")

-- Outgoing player actions (best coverage)
eventFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
eventFrame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")

-- Some clients also emit these when you affect friendly targets
eventFrame:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_HEAL")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF")
eventFrame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS")

local function IsIncomingHostileEvent(ev)
    return ev == "CHAT_MSG_COMBAT_HOSTILEPLAYER_HITS"
        or ev == "CHAT_MSG_COMBAT_HOSTILEPLAYER_MISSES"
        or ev == "CHAT_MSG_SPELL_HOSTILEPLAYER_DAMAGE"
        or ev == "CHAT_MSG_SPELL_HOSTILEPLAYER_MISSES"
        or ev == "CHAT_MSG_SPELL_PERIODIC_HOSTILEPLAYER_DAMAGE"
        or ev == "CHAT_MSG_SPELL_HOSTILEPLAYER_NODAMAGE"
end

local function IsOutgoingPlayerEvent(ev)
    return ev == "CHAT_MSG_SPELL_SELF_DAMAGE"
        or ev == "CHAT_MSG_SPELL_SELF_BUFF"
        or ev == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE"
        or ev == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS"
        or ev == "CHAT_MSG_COMBAT_SELF_HITS"
        or ev == "CHAT_MSG_COMBAT_SELF_MISSES"
        or ev == "CHAT_MSG_SPELL_FRIENDLYPLAYER_HEAL"
        or ev == "CHAT_MSG_SPELL_FRIENDLYPLAYER_BUFF"
        or ev == "CHAT_MSG_SPELL_PERIODIC_FRIENDLYPLAYER_BUFFS"
end

eventFrame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        EnsureDefaults()
        CreateMainFrame()
        CreateMinimapButton()
        RefreshStatus()
        Print(T("ADDON_LOADED"))
        return
    end

    if event == "PLAYER_FLAGS_CHANGED" then
        RefreshStatus()
        return
    end

    if deactivationRequested and IsPVPOn() then
        local msg = arg1

        if IsIncomingHostileEvent(event) then
            -- Incoming hostile events must affect player
            if ShouldResetIncoming(msg) then
                ResetDeactivationTimer(event)
                RefreshStatus()
            else
                Debug("Ignored incoming hostile text: " .. tostring(msg))
            end
            return
        end

        if IsOutgoingPlayerEvent(event) then
            -- Outgoing: only if YOU are the source
            if ShouldResetOutgoing(msg) then
                ResetDeactivationTimer(event)
                RefreshStatus()
            else
                Debug("Ignored outgoing text (not player source/result): " .. tostring(msg))
            end
            return
        end
    end

    if event == "UNIT_COMBAT" then
        -- UNIT_COMBAT fires on real combat results (hit/crit/etc). Avoid heals (spec).
        local unit = arg1
        local action = arg2
        local amount = arg4

        -- Incoming damage to player
        if unit == "player" and action == "WOUND" and amount and amount > 0 then
            ResetDeactivationTimer("unit_combat_in")
            return
        end

        -- Outgoing damage to target (best-effort; may not fire in all builds)
        if unit == "target" and action == "WOUND" and amount and amount > 0 then
            if UnitExists and UnitExists("target") and UnitCanAttack and UnitCanAttack("player", "target") then
                ResetDeactivationTimer("unit_combat_out")
                return
            end
        end
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
        Print(T("HELP_TITLE"))
        Print(T("HELP_TOGGLE"))
        Print(T("HELP_SHOW"))
        Print(T("HELP_HIDE"))
        Print(T("HELP_LOCK"))
        Print(T("HELP_UNLOCK"))
        Print(T("HELP_SCALE"))
        Print(T("HELP_CONFIG"))
        Print(T("HELP_DEBUG"))
        return
    end

    if msg == "show" then
        if mainFrame then mainFrame:Show() end
        PvpToggleTurtleDB.showFrame = true
        Print(T("FRAME_SHOWN"))
        return
    end

    if msg == "hide" then
        if mainFrame then mainFrame:Hide() end
        PvpToggleTurtleDB.showFrame = false
        Print(T("FRAME_HIDDEN"))
        return
    end

    if msg == "lock" then
        PvpToggleTurtleDB.lock = true
        UpdateLockIndicator()
        Print(T("LOCKED_MSG"))
        return
    end

    if msg == "unlock" then
        PvpToggleTurtleDB.lock = false
        UpdateLockIndicator()
        Print(T("UNLOCKED_MSG"))
        return
    end

    if string.find(msg, "^scale") == 1 then
        local num = tonumber(string.match(msg, "scale%s+([%d%.]+)"))
        if not num then
            Print(T("ERR_SCALE_NUMBER"))
            return
        end
        if num < 0.5 then num = 0.5 end
        if num > 2.0 then num = 2.0 end
        PvpToggleTurtleDB.scale = num
        if mainFrame then mainFrame:SetScale(num) end
        Print(string.format(T("SCALE_SET"), num))
        return
    end

    if msg == "config" then
        OpenOptionsFrame()
        return
    end

    if string.find(msg, "^debug") == 1 then
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
        return
    end

    TogglePvP()
    RefreshStatus()
end

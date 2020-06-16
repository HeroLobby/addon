local addonName, core = ...;
core.HeroLobbyBase = { };
local HeroLobbyBase = core.HeroLobbyBase;
local HeroLobbyConfig = { };
HeroLobbyBase.inviteeTable = { };
HeroLobbyBase.canInvite = false;
HeroLobbyBase.eventTitle = "";
local defaults = {
    theme = {
        r = 0;
        g = 0.8;
        b = 1;
        hex = "00ccff"
    }
}
-----------------------------------------------------------------
-----------------------------------------------------------------
function HeroLobbyBase:Toggle()
    local menu = HeroLobbyConfig or HeroLobbyBase:HeroLobbyConfigBuild();
    menu:SetShown(not menu:IsShown());
end

function HeroLobbyBase:GetThemeColor()
    local c = defaults.theme;
    return c.r, c.g, c.b, c.hex;
end

local waitTable = { };
local waitFrame = nil;

function HeroLobbyBase:Wait(delay, func, ...)
  if(type(delay)~="number" or type(func)~="function") then
    return false;
  end
  if(waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate",function (self,elapse)
      local count = #waitTable;
      local i = 1;
      while(i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        if(d>elapse) then
          tinsert(waitTable,i,{d-elapse,f,p});
          i = i + 1;
        else
          count = count - 1;
          f(unpack(p));
        end
      end
    end);
  end
  tinsert(waitTable,{delay,func,{...}});
  return true;
end

function HeroLobbyBase:CreateButton(point, relativeFrame, relativePoint, yOffset, xOffset, text)
    local button = CreateFrame("Button", nil, HeroLobbyConfig, "GameMenuButtonTemplate");
    button:SetPoint(point, relativeFrame, relativePoint, yOffset, xOffset);
    button:SetSize(140, 30);
    button:SetText(text);
    button:SetNormalFontObject("GameFontNormalLarge");
    button:SetHighlightFontObject("GameFontHighlightLarge");
    return button;
end

function HeroLobbyBase:BuildBackgroundFrame()
    HeroLobbyConfig = CreateFrame("Frame", "HeroLobby_Config", UIParent, "BasicFrameTemplateWithInset");
    HeroLobbyConfig:SetSize(325, 380);
    HeroLobbyConfig:SetPoint("CENTER", UIParent, "CENTER");
    HeroLobbyBase:CreateFrameTitle(addonName, HeroLobbyConfig);
    HeroLobbyConfig:SetMovable(true);
    HeroLobbyConfig:EnableMouse(true);
    HeroLobbyConfig:RegisterForDrag("LeftButton");
    HeroLobbyConfig:SetScript("OnDragStart", HeroLobbyConfig.StartMoving);
    HeroLobbyConfig:SetScript("OnDragStop", HeroLobbyConfig.StopMovingOrSizing);
end

function HeroLobbyBase:CreateFrameTitle(titleText, frame)
    frame.title = frame:CreateFontString(nil, "OVERLAY");
    frame.title:SetFontObject("GameFontHighlight");
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 5, 0);
    frame.title:SetText(titleText);
end

function HeroLobbyBase:AttachButtons()
    local createEventButton = HeroLobbyBase:CreateButton("BOTTOM", HeroLobbyConfig, "BOTTOM", 0, 10, "Import Event");
    createEventButton:SetScript("OnClick", HeroLobbyBase.CreateCalendarEvent);
end

function HeroLobbyBase:CanInvite() 
    HeroLobbyBase.canInvite = C_Calendar.CanSendInvite();
    if next(HeroLobbyBase.inviteeTable) == nil then
        return;         
    end
    if (HeroLobbyBase.canInvite) then
        HeroLobbyBase:InvitePlayer();
    end
end

function HeroLobbyBase:DelayCanInvite()
    HeroLobbyBase:Wait(2, HeroLobbyBase.CanInvite);
end

function HeroLobbyBase:InvitePlayer()
    if next(HeroLobbyBase.inviteeTable) == nil then 
        return;
    end
    local index, player = next(HeroLobbyBase.inviteeTable);
    core:Print("Inviting Player: " .. player);
    C_Calendar.EventInvite(player);
    table.remove(HeroLobbyBase.inviteeTable, 1);
    if next(HeroLobbyBase.inviteeTable) == nil then
        HeroLobbyBase:Wait(1, core.Print, " ", "Your event was created with title: " .. HeroLobbyBase.eventTitle);
    end
end

function HeroLobbyBase:CreateCalendarEvent()
    local importString = HeroLobbyConfig.editBox:GetText();
    local eventTable = { };
    local eventDateTable = { };
    local eventTimeTable = { };
    local eventTypeMap = {
        ["Raid"] = CALENDAR_EVENTTYPE_RAID,
        ["Dungeon"] = CALENDAR_EVENTTYPE_DUNGEON,
        ["PvP"] = CALENDAR_EVENTTYPE_PVP,
        ["Meeting"] = CALENDAR_EVENTTYPE_MEETING,
        ["Other"] = CALENDAR_EVENTTYPE_OTHER
    };

    -- regiter event and setscript for invites
    HeroLobbyConfig:RegisterEvent("CALENDAR_ACTION_PENDING");
    HeroLobbyConfig:SetScript("OnEvent", HeroLobbyBase.DelayCanInvite);
    
    -- create table for event meta data
    for key, value in string.gmatch(importString, "([^,]+):([^,]+)") do
        eventTable[key] = value;
    end

    HeroLobbyBase.eventTitle = eventTable.Title;

    -- create table for date
    for key, value in string.gmatch(eventTable.Date, "([%S]+)%p([%S]+)") do
        eventDateTable[key] = value;
    end

    -- create table for invitees
    for value in string.gmatch(eventTable.Heroes, "([%S]+)") do
        table.insert(HeroLobbyBase.inviteeTable, value);
    end

    -- create table for time
    for key, value in string.gmatch(eventTable.Time, "([%S]+)%p([%S]+)") do
        eventTimeTable[key] = value;
    end

    -- LoadAddOn("Blizzard_Calendar");
    C_Calendar.CreatePlayerEvent();
    C_Calendar.EventSetDate(eventDateTable.Month, eventDateTable.Day, eventDateTable.Year);
    C_Calendar.EventSetDescription(eventTable.Description);
    -- event:CalendarEventSetRepeatOption();
    C_Calendar.EventSetTime(eventTimeTable.Hour, eventTimeTable.Minute);
    C_Calendar.EventSetTitle(eventTable.Title);
    C_Calendar.EventSetType(eventTypeMap[eventTable.Type]);
    C_Calendar.AddEvent();
end

function HeroLobbyBase:HeroLobbyConfigBuild()
    HeroLobbyBase:BuildBackgroundFrame();
    HeroLobbyBase:AttachButtons();

    HeroLobbyConfig.scrollFrame = CreateFrame("ScrollFrame", nil, HeroLobbyConfig, "UIPanelScrollFrameTemplate");
    HeroLobbyConfig.scrollFrame:SetSize(283,300);
    HeroLobbyConfig.scrollFrame:SetPoint("TOPLEFT", HeroLobbyConfig, "TOPLEFT", 10, -30);
    HeroLobbyConfig.editBox = CreateFrame("EditBox", nil, HeroLobbyConfig.scrollFrame);
    HeroLobbyConfig.editBox:SetMultiLine(true);
    HeroLobbyConfig.editBox:SetFontObject(ChatFontNormal);
    HeroLobbyConfig.editBox:SetWidth(285);
    HeroLobbyConfig.scrollFrame:SetScrollChild(HeroLobbyConfig.editBox);
    HeroLobbyConfig.editBox:SetAutoFocus(true);
    HeroLobbyConfig:Hide();
    return HeroLobbyConfig;
end

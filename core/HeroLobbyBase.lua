local addonName, core = ...;
core.HeroLobbyBase = { };
local inviteString;
local HeroLobbyBase = core.HeroLobbyBase;
local HeroLobbyInviteFrame = { };
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
function HeroLobbyBase:Invite()
    local menu = HeroLobbyInviteFrame or HeroLobbyBase:HeroLobbyInviteFrameBuild();
    menu:SetShown(not menu:IsShown());
    HeroLobbyInviteFrame.editBox:SetText("");
end

function HeroLobbyBase:GetThemeColor()
    local c = defaults.theme;
    return c.r, c.g, c.b, c.hex;
end

local waitTable = { };
local waitFrame = nil;

function HeroLobbyBase:Wait(delay, func, ...)
  if (type(delay) ~= "number" or type(func) ~= "function") then
    return false;
  end

  if (waitFrame == nil) then
    waitFrame = CreateFrame("Frame","WaitFrame", UIParent);
    waitFrame:SetScript("onUpdate", function (self, elapse)
      local count = #waitTable;
      local i = 1;
      while (i<=count) do
        local waitRecord = tremove(waitTable,i);
        local d = tremove(waitRecord,1);
        local f = tremove(waitRecord,1);
        local p = tremove(waitRecord,1);
        
        if (d > elapse) then
          tinsert(waitTable, i, {d-elapse, f, p});
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
    local button = CreateFrame("Button", nil, HeroLobbyInviteFrame, "GameMenuButtonTemplate");
    button:SetPoint(point, relativeFrame, relativePoint, yOffset, xOffset);
    button:SetSize(140, 30);
    button:SetText(text);
    button:SetNormalFontObject("GameFontNormalLarge");
    button:SetHighlightFontObject("GameFontHighlightLarge");
    return button;
end

function HeroLobbyBase:BuildBackgroundFrame()
    HeroLobbyInviteFrame = CreateFrame("Frame", "HeroLobby_Config", UIParent, "BasicFrameTemplateWithInset");
    HeroLobbyInviteFrame:SetSize(325, 180);
    HeroLobbyInviteFrame:SetPoint("CENTER", UIParent, "CENTER");
    HeroLobbyBase:CreateFrameTitle(addonName, HeroLobbyInviteFrame);
    HeroLobbyInviteFrame:SetMovable(true);
    HeroLobbyInviteFrame:EnableMouse(true);
    HeroLobbyInviteFrame:RegisterForDrag("LeftButton");
    HeroLobbyInviteFrame:SetScript("OnDragStart", HeroLobbyInviteFrame.StartMoving);
    HeroLobbyInviteFrame:SetScript("OnDragStop", HeroLobbyInviteFrame.StopMovingOrSizing);
    
    local HeroLobbyText = HeroLobbyInviteFrame:CreateFontString(f, "OVERLAY", "GameTooltipText");
    HeroLobbyText:SetPoint("TOPLEFT", 10, -30);
    HeroLobbyText:SetText("Paste the HeroLobby invite string here.");
    HeroLobbyText:SetTextColor(230, 204, 128);
end

function HeroLobbyBase:CreateFrameTitle(titleText, frame)
    frame.title = frame:CreateFontString(nil, "OVERLAY");
    frame.title:SetFontObject("GameFontHighlight");
    frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 5, 0);
    frame.title:SetText("HeroLobby invite tool");
end

function HeroLobbyBase:AttachButtons()
    local createEventButton = HeroLobbyBase:CreateButton("BOTTOM", HeroLobbyInviteFrame, "BOTTOM", 0, 10, "Start inviting");
    createEventButton:SetScript("OnClick", HeroLobbyBase.StartInvites);
end

function HeroLobbyBase:StartInvites() 
    local amountOfPlayers = 0;
    local myName = UnitName("player");
    local rosterSize = GetNumGroupMembers() or 0;
    
    for inviteTarget in string.gmatch(inviteString, "([^;]+)") do
        amountOfPlayers = amountOfPlayers + 1
        InviteUnit(inviteTarget)
    end

    core:Print("Invites have started! " .. amountOfPlayers .. " players are invited.");
    HeroLobbyInviteFrame:Hide();
end

function HeroLobbyBase:HeroLobbyInviteFrameBuild()
    HeroLobbyBase:BuildBackgroundFrame();
    HeroLobbyBase:AttachButtons();
    HeroLobbyInviteFrame.scrollFrame = CreateFrame("ScrollFrame", nil, HeroLobbyInviteFrame, "UIPanelScrollFrameTemplate");
    HeroLobbyInviteFrame.scrollFrame:SetSize(280, 70);
    HeroLobbyInviteFrame.scrollFrame:SetPoint("TOPLEFT", HeroLobbyInviteFrame, "TOPLEFT", 13, -55);
    HeroLobbyInviteFrame.editBox = CreateFrame("EditBox", nil, HeroLobbyInviteFrame.scrollFrame);
    HeroLobbyInviteFrame.editBox:SetMultiLine(true);
    HeroLobbyInviteFrame.editBox:SetFontObject(ChatFontNormal);
    HeroLobbyInviteFrame.editBox:SetWidth(285);
    HeroLobbyInviteFrame.editBox:SetScript("OnEscapePressed", function(self) HeroLobbyInviteFrame:Hide() end);
    HeroLobbyInviteFrame.scrollFrame:SetScrollChild(HeroLobbyInviteFrame.editBox);
    HeroLobbyInviteFrame.editBox:SetScript("OnTextChanged", function(self) inviteString = self:GetText() end)
    HeroLobbyInviteFrame.editBox:SetAutoFocus(true);
    HeroLobbyInviteFrame:Hide();
    return HeroLobbyInviteFrame;
end

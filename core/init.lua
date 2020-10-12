local addonName, core = ...;

core.commands = {
    ["invite"] = core.HeroLobbyBase.Invite,
};

local function HandleSlashCommands(str)
    if (#str == 0) then
        core.commands.invite();
        return;
    end

    local args = { };
    for _, arg in pairs({ string.split(' ', str) }) do
        if(#arg > 0) then
            table.insert(args, arg);
        end
    end

    local path = core.commands;

    for id, arg in ipairs(args) do
        arg = string.lower(arg);
        if(path[arg]) then
            if(type(path[arg]) == "function") then
                path[arg](select(id + 1, unpack(args)));
                return;
            elseif (type(path[arg]) == "table") then
                path = path[arg];
            else
                core.commands.invite();
                return;
            end
        else
            core.commands.invite();
            return;
        end
    end
end

function core:Print(...)
    local hex = select(4, core.HeroLobbyBase:GetThemeColor());
    local prefix = string.format("|cff%s%s|r", hex:upper(), addonName .. ":");
    DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, tostringall(...)));
end

function core:init(event, name)
    if (name ~= "HeroLobby") then return end

    for i = 1, NUM_CHAT_WINDOWS do
        _G["ChatFrame" .. i .. "EditBox"]:SetAltArrowKeyMode(false);
    end

    -- SLASH_RELOADUI1 = "/rl";
    -- SlashCmdList.RELOADUI = ReloadUI;

    -- SLASH_FRAMESTK1 = "/fs";

    -- SlashCmdList.FRAMESTK = function() 
    --     LoadAddOn('Blizzard_DebugTools');
    --     FrameStackTooltip_Toggle();
    -- end

    -- slash commands 
    SLASH_HeroLobby1 = "/herolobby";
    SlashCmdList.HeroLobby = HandleSlashCommands;
    
    core.HeroLobbyBase:HeroLobbyInviteFrameBuild()
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", core.init);

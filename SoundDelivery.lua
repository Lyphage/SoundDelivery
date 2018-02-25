-- Konstanten
local SD_PREFIX = "SDT";
SD_ADDON_NAME =  "SoundDelivery";
SD_VERSION = "0.1.0.70300";
SD_MAX_ALIAS_LEN = 20;
SD_MIN_SEARCH_LEN = 3;
local SD_MIN_SOUND_DELAY = 3;


--globale Variabeln
SD_Tags ={};


-- lokale Variabeln
local moduleData = {};
local newestVersion = SD_VERSION;
local soundTimer = time();
local lastSender = nil;
local numPartyMembers = 0;
local soundHandle = nil;
local counter = 0;

--local verRequest = false;

--gespeicherte Einstellungen
SD_SETTINGS = { };

local defaults = {
  ["broadcast"] = {
    ["GUILD"] = true,
    ["RAID"] = true,
    ["BATTLEGROUND"] = true,
    ["PARTY"] = true,
  },

  ["quickbutton"] =
  {
    ["SHOWN"] = true,
  },
  ["aliases"] =  {},

  ["channel"] =
  {
    ["CHANNEL"] = 2
  }
}


function SD_init()
  --Checks if new SavedVariables are added
  for key, value in pairs(defaults) do
    if SD_SETTINGS[key] == nil then
      SD_SETTINGS[key] = value
    end
  end
  RegisterAddonMessagePrefix(SD_PREFIX);  
  
    SlashCmdList["SD"] = SD_showUI;
    SLASH_SD1 = "/sd";

    SlashCmdList["SDHELP"] = SD_help;
    SlashCmdList["SDHELP"] = SD_help;
    SLASH_SDHELP1 = "/sdh";
    SLASH_SDHELP2 = "/sdhelp";

    SlashCmdList["SDBROADCAST"] = SD_broadcast;
    SLASH_SDBROADCAST1 = "/sdb";
    SLASH_SDBROADCAST2 = "/sdbroadcast";

    SlashCmdList["SDPARTY"] = SD_party;
    SLASH_SDPARTY1 = "/sdp";
    SLASH_SDPARTY2 = "/sdparty";

    SlashCmdList["SDRAID"] = SD_raid;
    SLASH_SDRAID1 = "/sdr";
    SLASH_SDRAID2 = "/sdraid";

    SlashCmdList["SDGUILD"] = SD_guild;
    SLASH_SDGUILD1 = "/sdg";
    SLASH_SDGUILD2 = "/sdguild";

    SlashCmdList["SDLISTEN"] = SD_listen;
    SLASH_SDLISTEN1 = "/sdl";
    SLASH_SDLISTEN2 = "/sdlisten";

    SlashCmdList["SDALIAS"] = SD_alias;
    SLASH_SDALIAS1 = "/sda";
    SLASH_SDALIAS2 = "/sdalias";

    SlashCmdList["SDFIND"] = SD_find;
    SLASH_SDFIND1 = "/sdf";
    SLASH_SDFIND2 = "/sdfind";

    SlashCmdList["SDSTOP"] = SD_stop;
    SLASH_SDSTOP1 = "/sds";
    SLASH_SDSTOP2 = "/sdstop";

    SlashCmdList["SDQBUI"] = SD_QBUI;
    SLASH_SDQBUI1 = "/sdqb";



    -- WQUI:UpdateCheckButtons(); --verschoben in WoWQuote2UI init

  WQUIB:Switch(SD_SETTINGS.quickbutton.SHOWN);
  SD_msg("msg_loaded", SD_ADDON_NAME, SD_VERSION);
 

  SD_importTags(SD_BASE_TAGS);
  SD:UnregisterEvent("ADDON_LOADED");
  WQUI:UpdateCheckButtons();
  --Loads last selected channel
  WQUI.SetID(SD_SETTINGS.channel.CHANNEL);

end

function SD_resetLastSender() --for testing purposes only
  SD_print("lastSender \""..tostring(lastSender).."\" will be reset to nil");
  lastSender = nil;
end

function SD_guild(id)
  SD_send(id, "GUILD");
end

function SD_party(id)
  if GetNumGroupMembers() ~= 0 then
    SD_send(id, "PARTY");
  else
    SD_msg("err_not_in_party");
  end
end

function SD_raid(id)
  local inInstance, instanceType = IsInInstance();
  if (inInstance and instanceType == "pvp") then
    SD_send(id, "BATTLEGROUND");
  elseif IsInRaid() ~= 0 then
    SD_send(id, "RAID");
  else
    SD_party(id);
  end
end

function SD_listen(id)
  if (not id or SD_trim(id) == "") then
    return;
  end

  local moduleid, quoteid, media, path = SD_getQuoteByID(id);
  if not media then
    moduleid, quoteid, media, path = SD_getQuoteByAlias(id);
  end

  if media then
    SD_print(media.id..": [ " .. media.msg .. " ]");
    SD_play(media, path);
  else
    SD_notFound(id);
  end

end

function SD_broadcast(cmd)

  -- Einstellungen anzeigen
  if tostring(cmd) == "" then
    SD_showSettings();
    return;
  end

  local arg1, arg2 = SD_getCmd(cmd);

  arg1 = string.lower(arg1);
  arg2 = string.lower(arg2);

  --2. argument prüfen, da erstes im spezialfall all nicht geprüft werden darf
  if (arg2 ~= "on" and arg2 ~= "off") then
    SD_msg("err_miss_switch");
    return;
  end

  -- spezialfall: alle channel an und aus schalten
  if (arg1 == "all") then
    SD_broadcast("p " .. arg2);
    SD_broadcast("g " .. arg2);
    SD_broadcast("r " .. arg2);
    return;
  end

  -- 1. argument prüfen für normalen Fall
  if not string.find(arg1,"[prg]") then
    SD_msg("err_miss_channel");
    return;
  end


  -- einzelne Channels an und abstellen
  if arg2 == "on" then
    if arg1 == "p" then
      SD_SETTINGS.broadcast.PARTY = true;
      SD_msg("msg_chan_on", SD_channels.PARTY.name);
    end
    if arg1 == "g" then
      SD_SETTINGS.broadcast.GUILD = true;
      SD_msg("msg_chan_on", SD_channels.GUILD.name);
    end
    if arg1 == "r" then
      SD_SETTINGS.broadcast.RAID = true;
      SD_SETTINGS.broadcast.BATTLEGROUND = true;
      SD_msg("msg_chan_on", SD_channels.RAID.name);
    end
  end

  if arg2 == "off" then
    if arg1 == "p" then
      SD_SETTINGS.broadcast.PARTY = false;
      SD_msg("msg_chan_off", SD_channels.PARTY.name);
    end
    if arg1 == "g" then
      SD_SETTINGS.broadcast.GUILD = false;
      SD_msg("msg_chan_off", SD_channels.GUILD.name);
    end
    if arg1 == "r" then
      SD_SETTINGS.broadcast.RAID = false;
      SD_SETTINGS.broadcast.BATTLEGROUND = false;
      SD_msg("msg_chan_off", SD_channels.RAID.name);
    end
  end

  -- UI Updaten
  WQUI:UpdateCheckButtons();

end


function SD_showSettings()
  SD_print(string.format(SD_MSG["msg_conf_title"],SD_ADDON_NAME));
  local tab = {};
  for i,v in pairs(SD_SETTINGS.broadcast) do
    if v then
      tab[SD_channels[i]["name"]] = "on";
    else
      tab[SD_channels[i]["name"]] = "off";
    end
  end
  SD_printTable(tab, true);
end


function SD_send(id, system)
  if (not SD_SETTINGS.broadcast[system]) then
    SD_msg("err_sendchan_off", SD_channels[system].name);
    return;
  end
  if (not id or SD_trim(id) == "") then
    return;
  end

  local moduleid, quoteid, media = SD_getQuoteByID(id);
  if not media then
    moduleid, quoteid, media = SD_getQuoteByAlias(id);
  end


  if media then
    SendAddonMessage(SD_PREFIX, ("cmd=play, moduleid="..moduleid..", quoteid="..moduleid..":"..quoteid), system); -- senden neues Protokoll das benutzt man ums unter leute zu schicken
    if moduleid == "default" then
      SendAddonMessage(SD_PREFIX, quoteid, system);
    elseif moduleid == "SD" then
      SendAddonMessage(SD_PREFIX, quoteid+799, system);
    end


  else
    SD_notFound(id);
  end

end

function SD_getQuoteByID(id)
  --SD_print("SD_getQuoteByID("..id..")");
  --SD_print(tostring(string.match(id, "%s*(%w*):?(%w*)%s*")));

  local moduleid=nil;
  local quoteid=nil;
  local media=nil;
  local path=nil;

  if id and SD_trim(id)~="" then
    moduleid, quoteid = string.match(id, "%s*(%w*):?(%w*)%s*");
    if quoteid == "" then
      quoteid=moduleid;
      moduleid="default";
    end
    --SD_print("SD_getQuoteByID(): resolved moduleid: "..tostring(moduleid).." quoteid: "..tostring(quoteid));
    media, path = SD_getMedia(moduleid, quoteid);
    --SD_print("SD_getQuoteByID(): resolved media: "..tostring(media));
  end

  return moduleid, quoteid, media, path;
end

function SD_getQuoteByAlias(alias)
  if SD_SETTINGS.aliases[alias] then
    return SD_getQuoteByID(SD_SETTINGS.aliases[alias]);
  else
    return nil, nil, nil, nil;
  end

end

function SD_onEvent(event, ...)

  --switch events
  if (event == "ADDON_LOADED" and select(1,...) == SD_ADDON_NAME) then  --why VARIABLES_LOADED? check!
    SD_init();
  elseif (event == "PLAYER_ENTERING_WORLD") then
    SD_sendVersion("GUILD", true);
    SD:UnregisterEvent("PLAYER_ENTERING_WORLD");
  elseif (event == "CHAT_MSG_ADDON" and select(1,...) == SD_PREFIX) then
    -- SD AddonMessage
    local args = {...};
    local cmdlist;

    --switch protocols
    if (string.find(args[2], "=")) then
      --new protocol
      cmdlist =  SD_parseArguments(args[2]);
      lastSender = args[4];
    elseif (lastSender ~= args[4] and tonumber(args[2])) then
      --old protocol
      --convert old protocol event to new protocol event --> handle as play cmd
      cmdlist = SD_convertOldProtocol(args[2]);
    else
      return;
    end

    --switch comands
    if (cmdlist.cmd == "play") then
      --handle play cmd
      SD_handlePlayCmd(cmdlist, args[3], args[4])
    elseif (cmdlist.cmd == "ver") then
      --handle ver cmd
      SD_handleVersion(cmdlist, args[3]);
    else
      --SD_print("unknown cmd, cmdlist:")
      --SD_printTable(cmdlist,true);
    end

  elseif (event == "PARTY_MEMBERS_CHANGED") then
    -- send Version into Party/Raid
    local args = {...};
    SD_partyMembersChanged();
  end

end


function SD_handlePlayCmd(cmdlist, system, sender)
  if (cmdlist.moduleid and cmdlist.quoteid) then
    local media, path = SD_getMedia(cmdlist.moduleid, cmdlist.quoteid);
    if (media and path and SD_SETTINGS.broadcast[system]) then
      if (cmdlist.silent ~= "true") then
        SD_showMsg(sender, media.msg, media.len, system);
      end
      SD_play(media, path);
    else
      --SD_print("handlePlayCmd: No playable media found");
    end
  end
end

function SD_convertOldProtocol(id)
  local cmdlist = {["cmd"] = "play", };
  id = tonumber(id);

  if (id > 800) then
    cmdlist.moduleid = "sd";
    cmdlist.quoteid = id - 799;
  else
    cmdlist.moduleid = "default";
    cmdlist.quoteid = id;
  end

  --SD_print("old protocol converted:");
  --SD_printTable(cmdlist, true);

  return cmdlist;
end

function SD_showMsg(sender, msg, t, system)
  local playerlink = "|Hplayer:" .. sender .. "|h[" .. sender .. "]|h";
  local out = SD_channels[system].color .. "[" .. SD_channels[system].name .. "] " .. playerlink .. ": [ " .. msg .. " | Duration: "..t.." seconds".." ]";
  DEFAULT_CHAT_FRAME:AddMessage(out);
end


function SD_partyMembersChanged()

  local num = GetNumGroupMembers();
  local inInstance, instanceType = IsInInstance();

  if (num > numPartyMembers and newestVersion == SD_VERSION) then
    --SD_print("SD_sendVersion(\"RAID\");");
    if (inInstance and instanceType == "pvp") then
      SD_sendVersion("BATTLEGROUND");
    else
      SD_sendVersion("RAID");
    end
  elseif (num == 0) then
    num = GetNumSubgroupMembers();
    if (num > numPartyMembers and newestVersion == SD_VERSION) then
      --SD_print("SD_sendVersion(\"PARTY\");");
      SD_sendVersion("PARTY");
    end
  end
  numPartyMembers = num;

  --SD_print("PARTY_MEMBERS_CHANGED: "..numPartyMembers);
end

function SD_handleVersion(cmdlist, system)
  --SD_print("handleVersion: "..tostring(cmdlist.ver));
  if (not cmdlist.ver) then
    --keine Version mit übertragen --> request --> senden
    SD_sendVersion(system, false, (cmdlist.force == "true"));
  elseif (cmdlist.mod == SD_ADDON_NAME and cmdlist.ver>newestVersion) then
    --SD betreffende Versionsinfo mit neuerer Version
    newestVersion = cmdlist.ver;
    getglobal(WQUI:GetName().."Title"):SetTextColor(1,0,0);
    getglobal(WQUI:GetName().."Title"):SetText(string.format(SoundDeliveryUI_Localization.DIALOG_TITLE_NEW_VERSION,newestVersion));
  end

end

function SD_sendVersion(system, request, force)
  --SD_print("SD_sendVersion("..system..")");
  if (request) then
    SendAddonMessage(SD_PREFIX, "cmd=ver", system);
  elseif (newestVersion == SD_VERSION or force) then
    SendAddonMessage(SD_PREFIX, ("cmd=ver, ver="..SD_VERSION..", mod="..SD_ADDON_NAME), system);
  end
end


function SD_importTags(tags)
  for key, value in pairs(tags) do
    if (not SD_Tags[key]) then
      SD_Tags[key] = value
    end
  end
end

function SD_getModuleData()
  return moduleData;
end

function SD_InitModule(module)
  moduleData[module.moduleid] = module;
  if module.name then
    if (not SD_Tags[module.moduleid]) then
      SD_Tags[module.moduleid] = module.name
    end
  end
  if module.tags then
    SD_importTags(module.tags);
  end
  --SD_print("module inited: "..module.moduleid);
end

function SD_getMedia(moduleid, quoteid)
  --SD_print("SD_getMedia("..moduleid..", "..quoteid.."); type(quoteid): "..type(quoteid));

  local media = nil;
  local path = nil;
  local index;
  quoteid = tostring(quoteid);
  if string.find(quoteid, ":") then
    quoteid = string.match(quoteid, "%s*[^%:]*%:(%d*)")
    index = tonumber(quoteid);
  else
    index = tonumber(quoteid);
  end
  --SD_print("getMedia: index: "..tostring(index));
  --SD_print("getMedia: quoteid: "..quoteid);
  --SD_print("moduleData[moduleid].mediadata[index].id == quoteid "..tostring(moduleData[moduleid].mediadata[index].id == quoteid));

  if (moduleData[moduleid]) then --modul vorhanden

    if (index and index<=#moduleData[moduleid].mediadata and moduleData[moduleid].mediadata[index] and (moduleData[moduleid].mediadata[index].id == quoteid or moduleData[moduleid].mediadata[index].id == moduleid..":"..quoteid)) then
      media = moduleData[moduleid].mediadata[index];
      --SD_print("getMedia: found by index");
    else
      --SD_print("getMedia: searching...");
      for i,v in pairs(moduleData[moduleid].mediadata) do
        --SD_print(v.id);
        if (v.id == quoteid or v.id == moduleid..":"..quoteid) then
          media = v;
          --SD_print("getMedia: found by search");
          break;
        end
      end
    end
    path = moduleData[moduleid].mediapath;
  else
    --SD_print("moduleid not found: "..tostring(moduleData[moduleid]));
  end

  --SD_print("getMedia() returns: "..tostring(media)..", "..tostring(path));
  return media, path;

end


function SD_parseArguments(input)
  -- returns a keyed table of values
  -- arguments are divided by commata (",")
  -- keys are divided from their values by an equal sign ("=")
  -- keys and values may not begin or end with whitespace characters
  --    (whitespace is trimmed)
  -- keys and values may not contain comma or equal sign characters ("," "=")
  --    (there is currently no way to escape special characters; this may change in the future)
  local result = {}
  local length = string.len(input)
  local argument
  local cursor = 1
  while cursor <= length do
    argument, cursor = string.match(input, "([^,]*),?()", cursor)
    local key, value = string.match(argument, "%s*([^=%s]*)%s*=%s*(.*)%s*$")
    if key and value then
      result[key] = value
    else
      -- error: argument without "="
    end
  end
  return result
end

--Universal Function: Plays the media.
--Changes made => if the Duration (delay) is greater than 10 seconds then you can't play
--another file that is longer than 10 seconds, but you can still play shorter sounds.
--You can spam shorter sounds or play them while the music is playing.
--Old music stops playing when someone else plays a new music.
--Sound Output: changed to "Dialog" Sound channel.

function SD_play(media, path)                     --
  local delay = SD_MIN_SOUND_DELAY;
  local willPlay;
  local merker
  local file = path .. media.file;
  if (type(media.len)=="number") then
    delay = media.len;
  end

  if (delay >= 10) then
    delay = 10;
  else
    PlaySoundFile(file, "Dialog");
  end
  if (time() >= soundTimer) then
    soundTimer = time()+delay;
    if (delay == 10) then
      if(soundHandle == nil) then
      else
        StopSound(soundHandle)
      end
      willPlay, soundHandle = PlaySoundFile(file, "Dialog");
    end
  end
  --C_Timer.After(3, SD_singleStop(soundHandle));
  --if (merker > 0) then
  --C_Timer.After(media.len+1, function() then StopSound(soundHandle[merker]) end);
  --end
end

--Stops the current playing sound file if it's duration is longer than 10 seconds
--Function is called by the stopButton in WoWQuote2UI.xml and the play function

function SD_stop()
  if (soundHandle == nil)then
  else
    StopSound(soundHandle);
  end
end

--Chat Command function: /wqf chat command

function SD_find(str)
  if str ~= nil then
    str = SD_trim(string.lower(str));
  end
  if string.len(str) < SD_MIN_SEARCH_LEN then
    SD_msg("err_search_len",SD_MIN_SEARCH_LEN);
    return;
  end;
  local found, count = SD_search(str);
  SD_msg("msg_search_count",count);

  local foundToPrint = {};

  for i,v in pairs(found) do
    foundToPrint[v.id] = v.msg;
  end
  SD_printTable(foundToPrint, true);


end;

--Chat Command function: Searches all modules for any media containinfg the str String

function SD_search(str)
  local result = {};
  local searchCount = 0;
  str = string.lower(str);

  for moduleid, module in pairs(moduleData) do
    --SD_print("SD_search: searching in module: "..tostring(module.name));
    for id, media in pairs(module.mediadata) do
      --SD_print("SD_search: searching in quote: "..tostring(media.id).." --> "..media.msg) ;
      if string.find(string.lower(media.msg), str) then
        --SD_print("SD_search: found: "..tostring(media.msg));
        table.insert(result, media);
        searchCount= searchCount+1;
      end
    end
  end

  --SD_print("SD_search: "..searchCount.." matches found for \""..str.."\"");
  return result, searchCount;
end

--Chat Command function: returns a valid command

function SD_getCmd(msg)
  if (msg) then
    local a,b=string.find(msg, "[^%s]+");
    if (not ((a==nil) and (b==nil))) then
      local cmd=string.lower(string.sub(msg,a,b));
      return cmd, string.sub(msg,string.find(cmd,"$")+1);
    else
      return "";
    end;
  end;
end;

--Universal function: trims a string and returns invalid letters

function SD_trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

--Universal function: Shows the SD GUI

function SD_showUI()
  WQUI:Toggle();
end

function SD_QBUI()
  WQUIB:Switch(not(SD_SETTINGS.quickbutton.SHOWN));
  SD_SETTINGS.quickbutton.SHOWN = not(SD_SETTINGS.quickbutton.SHOWN);
end

--Universal function: Error if the quote wasn't found

function SD_notFound(id)
  SD_msg("err_quote_not_found",id);
  PlaySound("TellMessage");
end

--Universal function: Prints a msg, that's it!

function SD_print(msg)
  DEFAULT_CHAT_FRAME:AddMessage(msg,0.5,0.5,0.9);
end

--Universal function: Calls the SD_print(msg) function

function SD_msg(msg,p1,p2,p3)
  SD_print(SD_ADDON_NAME .. ": " .. string.format(SD_MSG[msg],p1,p2,p3));
end

--Chat Command function: Prints the SD_HELP in the Localization file

function SD_help()
  SD_printTable(SD_HELP);
end

--Chat Command function: Prints a list I guess

function SD_printTable(t,show)
  for i,v in pairs(t) do
    local msg = "|cff7090ff" .. tostring(v);
    if (show) then
      msg = "|cffffffff" .. tostring(i) .. " : " .. msg;
    end
    DEFAULT_CHAT_FRAME:AddMessage(msg,0.5,0.5,0.9);
  end
end

--Chat Command function: I don't like those alias things tho they are kinda cool

function SD_alias(cmd)                              --setzt Aliasse mit /wqa
  local alias, id = SD_getCmd(cmd);
  if (alias == nil or SD_trim(alias) == "") then     --gesetzte Aliasse anzeigen für keine Parameter
    SD_msg("msg_show_aliases");
    SD_printTable(SD_SETTINGS.aliases, true);
    return;
  end

  if (id == nil or SD_trim(id) == "") then           --alias Löschen für nur einen Parameter
    if (SD_SETTINGS.aliases[alias]) then
      SD_SETTINGS.aliases[alias] = nil;
      SD_msg("msg_alias_disabled",alias);
    else
      SD_msg("err_alias_not_found",alias);
    end;
    return;
  end
  -- alias auf id setzen, falls id gültig
  local moduleid, quoteid, media = SD_getQuoteByID(id);

  if not media then                                   --id gültig?
    SD_notFound(id);
    return;
  end

  if alias ~= nil and alias ~= "" and string.len(alias)<SD_MAX_ALIAS_LEN and string.find(alias,'^[%a]+[%w]*$') ~= nil then --alias Gültig?
    SD_SETTINGS.aliases[alias] = media.id;
    SD_msg("msg_alias_set",alias, media.id);
    return;
  else
    SD_msg("err_wrong_alias");
  end
end

--Universal Function: returns filtered Media and returns the list

function SD_getFilteredMedia(tag)
  --SD_print("getFilteredMedia("..tostring(tag)..")");
  --SD_print("getFilteredMedia: moduleData length: "..#moduleData);
  local result = {};

  if tag then
    for moduleid, module in pairs(moduleData) do
      for i, media in pairs(module.mediadata) do
        if media.tags then
          for i, quotetag in ipairs(media.tags) do
            if quotetag == tag[1] then
              table.insert(result, media);
            end
          end
        end
        if tag[1] == moduleid then
          table.insert(result, media);
        end
      end
    end
  else
    for moduleid, module in pairs(moduleData) do
      for i, media in pairs(module.mediadata) do
        table.insert(result, media);
      end
    end
  end

  --SD_print("getFilteredMedia: return table length: "..#result);

  return result;
end

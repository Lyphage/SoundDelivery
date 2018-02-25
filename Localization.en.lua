if (not("deDE" == GetLocale())) then

SD_BASE_TAGS = {
	--["hi"] = "Hi",
	--["bye"] = "Bye",
	--["positive"] = "Emotions (positive)",
	--["negative"] = "Emotions (negative)",
	--["pvp"] = "PvP",
	--["pve"] = "PvE",
	--["announce"] = "Announcements",
	--["group"] = "In a party",
	--["music"] = "Music",
	--["priest"] = "Priest",
	--["hunter"] = "Hunter",
	--["rogue"] = "Rogue",
	--["warlock"] = "Warlock",
	--["mage"] = "Mage",
	--["paladin"] = "Paladin",
	--["schaman"] = "Shaman",
	--["warrior"] = "Warrior",
	--["druid"] = "Druid",
	--["women"] = "Woman",
	--["men"] = "Men",
	--["pause"] = "Pause",
	--["music"] = "Music",
	--["sound"] = "Sound",
}

SD_channels = {
    ["GUILD"] = { ["name"] = "Guild", ["color"] = "|cff40ff40" },
    ["PARTY"] = { ["name"] = "Group", ["color"] = "|cffaaaaff" },
    ["RAID"] = { ["name"] = "Raid", ["color"] = "|cffff7f00"},
    ["BATTLEGROUND"] = { ["name"] = "Battleground" , ["color"] = "|cffff7f00" },
};

SD_HELP = {
    "--- SoundDelivery Help ---\n",
	"|cffffffff- /sdh : |r |cff7090ffShows this help text",
    "|cffffffff- /sdb [channel] [on|off]: |r |cff7090ffShows or configures all channels you are listening to for quotes. Possilble channels: p(arty), r(aid) oder g(uild). \"all\" to turn off/on all channels",
    "|cffffffff- /sdf <String>: |r |cff7090ffLists all quotes, that contain the entered string",
    "|cffffffff- /sda <Name> [Quote-ID]: |r |cff7090ffDefines a user defined name for the entered quote",
    "|cffffffff- /sdp <Quote-ID or Name>: |r |cff7090ffSend Quote to the Group channel",
    "|cffffffff- /sdg <Quote-ID or Name>: |r |cff7090ffSend Quote to the Guild channel",
    "|cffffffff- /sdr <Quote-ID or Name>: |r |cff7090ffSend Quote to the Raid channel",
    "|cffffffff- /sdl <Quote-ID or Name>: |r |cff7090ffTest Quote local test listening",
	"|cffffffff- /sds: |r |cff7090ffStops the current Music file",
  "|cffffffff- /sdqb |r |cff7090ffHides the Quickbutton until enabled again",
};

SD_MSG = {
	["msg_loaded"] = "%s v%s loaded. type /sdh for help, /sd to show the GUI",
	["msg_cat_title"] = "%s - Available Categories:",
	["msg_conf_title"] = "%s - Available Broadcast-settings:",
	["msg_qlist_title"] = "\n%s - Quotes containing '%s':",
	["err_cat_id"] = "Invalid Category-ID! /sdc lists all valid categories.",
	["err_quote_not_found"] = "Quote-ID \"%s\" not found!",
	["err_miss_channel"] = "Channel has to be  p, r or g",
	["err_miss_switch"] = "Please enter on or off",
	["err_wrong_alias"] = "Invalid name. Only enter a combination of letters and numbers. The first letter has to be a letter. The name may only be " .. SD_MAX_ALIAS_LEN .. " long.", -- m�glicherweise nicht erlaubt
	["err_alias_not_found"] = "Quote-ID %s has no defined name.",
	["msg_alias_disabled"] = "User defined name '%s' removed.",
	["msg_alias_set"] = "Name '%s' was set for Quote-ID '%s'.",
	["msg_chan_on"] = "Receiver activated for '%s'.",
	["msg_chan_off"] = "Receiver deactivated for '%s'.",
	["err_search_len"] = "String has to be at least %s long.",
	["msg_search_count"] = "%s Quotes found.",
    ["err_sendchan_off"] = "Could not send because the channel |cffffffff%s|cff7090ff is deactivated.",
    ["err_not_in_party"] = "You are not in a group!",
    ["msg_show_aliases"] = "Currently user defined names:",
};

end

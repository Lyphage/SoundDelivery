if (("deDE" == GetLocale())) then
SD_BASE_TAGS = {
	--["hi"] = "Hi",
	--["bye"] = "Bye",
	--["positive"] = "Emotionen (positiv)",
	--["negative"] = "Emotionen (negativ)",
	--["pvp"] = "PvP",
	--["pve"] = "PvE",
	--["announce"] = "Ansagen",
	--["group"] = "In der Gruppe",
	--["music"] = "Musik",
	--["priest"] = "Priester",
	--["hunter"] = "Jäger",
	--["rogue"] = "Schurke",
	--["warlock"] = "Hexer",
	--["mage"] = "Magier",
	--["paladin"] = "Paladin",
	--["schaman"] = "Schamane",
	--["warrior"] = "Krieger",
	--["druid"] = "Druide",
	--["women"] = "Frauen",
	--["men"] = "Männer",
	--["pause"] = "Pause",
	--["sound"] = "Sound",
}

SD_channels = {
    ["GUILD"] = { ["name"] = "Gilde", ["color"] = "|cff40ff40" },
    ["PARTY"] = { ["name"] = "Gruppe", ["color"] = "|cffaaaaff" },
    ["RAID"] = { ["name"] = "Schlachtzug", ["color"] = "|cffff7f00"},
    ["BATTLEGROUND"] = { ["name"] = "Schlachtfeld" , ["color"] = "|cffff7f00" },
};

SD_HELP = {
    "--- SoundDelivery HILFE ---\n",
	"|cffffffff- /sdh : |r |cff7090ffZeigt diese Hilfe an",
    "|cffffffff- /sdb [channel] [on|off]: |r |cff7090ffZeigt an oder verwaltet die Einstellungen für den Channel-Empfang von Quotes. Mögliche Channels sind: p(arty), r(aid) oder g(uild). \"all\" um alle ein/aus zu schalten",
    "|cffffffff- /sdf <Zeichenkette>: |r |cff7090ffListet alle Quotes auf, die die entsprechende Zeichenkette enthalten",
    "|cffffffff- /sda <Alias> [Quote-ID]: |r |cff7090ffWeist einem Quote ein userdefiniertes Namensalias zu. Wenn die Aliasname-Angabe fehlt, wird das alte Alias gelöscht. Ohne Argumente werden die gesetzten Aliasse angezeigt.",
    "|cffffffff- /sdp <Quote-ID|Alias>: |r |cff7090ffQuote in den Gruppenchannel posten",
    "|cffffffff- /sdg <Quote-ID|Alias>: |r |cff7090ffQuote in den Gildenchannel posten",
    "|cffffffff- /sdr <Quote-ID|Alias>: |r |cff7090ffQuote in den Raidchannel posten",
    "|cffffffff- /sdl <Quote-ID|Alias>: |r |cff7090ffQuote lokal probehören",
	"|cffffffff- /sds |r |cff7090ffStoppt Musik die abgepesielt wird",
  "|cffffffff- /sdqb |r |cff7090ffVersteckt den Quickbutton bis er wieder eingeschalten wird",
};

SD_MSG = {
	["msg_loaded"] = "%s v%s geladen. /sdh eintippen für Konsolenhilfe, /sd um das graphische User-Interface zu öffnen",
	["msg_cat_title"] = "%s - Verfügbare Kategorien:",
	["msg_conf_title"] = "%s - Aktuelle Broadcast-Einstellungen:",
	["msg_qlist_title"] = "\n%s - Quotes aus '%s':",
	["err_cat_id"] = "Gültige Kategorien-ID erwartet! /sdc zeigt eine Übersicht.",
	["err_quote_not_found"] = "Quote-ID \"%s\" nicht gefunden!",
	["err_miss_channel"] = "Channel muss  p, r oder g sein.",
	["err_miss_switch"] = "Bitte on oder off angeben.",
	["err_wrong_alias"] = "Ungültiges Alias angegeben. Erlaubt ist nur eine Folge aus Buchstaben oder Zahlen. Das erste Zeichen muss ein Buchstabe sein. Das Alias darf maximal " .. SD_MAX_ALIAS_LEN .. " Zeichen lang sein.", -- m�glicherweise nicht erlaubt
	["err_alias_not_found"] = "Quote-ID %s hat kein definiertes Alias.",
	["msg_alias_disabled"] = "Alias '%s' wurde entfernt.",
	["msg_alias_set"] = "Alias '%s' wurde gesetzt für Quote-ID '%s'.",
	["msg_chan_on"] = "Empfang auf Channel '%s' wurde AKTIVIERT.",
	["msg_chan_off"] = "Empfang auf Channel '%s' wurde DEAKTIVIERT.",
	["err_search_len"] = "Suchzeichenfolge muss mindestens %s Zeichen lang sein.",
	["msg_search_count"] = "%s Quotes gefunden.",
    ["err_sendchan_off"] = "Kann nicht senden, da der Channel |cffffffff%s|cff7090ff deaktiviert ist.",
    ["err_not_in_party"] = "Du bist in keiner Gruppe!",
    ["msg_show_aliases"] = "Momentan gesetzte Aliasse:",
};

end

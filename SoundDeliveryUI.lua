--BINDING_HEADER_WOWQUOTE_HEADER = "WoWQuote"
--BINDING_NAME_WOWQUOTE_TOGGLE = "Toggle WoWQuote"



WQUI = {
	NUM_DISPLAYABLE = 20,  -- maxmimum number of quotes that are visible at a time
	sortNumber = 0,

	CategoryDropDown = {}, -- hold functions for the Category DropDown
	ChannelDropDown = {},  -- hold functions for the Channel DropDown
	DisplayedItems = {},   -- all quotes displayed for the current tag and search pattern
    FilteredItems = {},    -- all quotes displayed for the current tag


	Quote = SD_guild,      -- the quote function that is used for posting quotes
	Channels = {
		{ name=SD_channels.PARTY.name, func=SD_party },
		{ name=SD_channels.GUILD.name, func=SD_guild },
		{ name=SD_channels.RAID.name, func=SD_raid },
        { name=SoundDeliveryUI_Localization.TEST_LISTEN_CHANNEL, func=SD_listen },
	},

	Sorters = {
		ByMessage = function(a, b) return (a.msg < b.msg) end,
		ByMessageR = function(a, b) return (a.msg > b.msg) end,
		ByID = function(a, b) return (a.id < b.id) end,
		ByIDR = function(a, b) return (a.id > b.id) end,
		ByDuration = function(a, b) return (a.len < b.len) end,
		ByDurationR = function(a, b) return (a.len > b.len) end,
		--if a value is not a string it will be automatically smaller than any string
		ByTag = function(a, b) if(not(type( b.tag ) == "string")) then return false end if(not(type( a.tag ) == "string")) then return true else return( a.tag < b.tag ) end end,
		ByTagR = function(a, b) if(not(type( a.tag ) == "string")) then return false end if(not(type( b.tag ) == "string")) then return true else return( a.tag > b.tag ) end end,
	},

	Sorter = function(a, b) return (a.msg < b.msg) end,

}

WQUIB ={

}


function WQUI:Msg(msg)
	DEFAULT_CHAT_FRAME:AddMessage(msg, 1.0, 0.5, 0.5)
end

function WQUI:Toggle()
	if (WQUI:IsVisible()) then
		HideUIPanel(WQUI)
	else
		ShowUIPanel(WQUI)
	end
end

function WQUI:Localize()
	local L = SoundDeliveryUI_Localization
	local name = self:GetName()

	getglobal(name.."Title"):SetText(L.DIALOG_TITLE)
	self.Columns.Text:SetText(L.COLUMN_TEXT)
	self.Columns.ID:SetText(L.COLUMN_DURATION)
	self.Columns.t:SetText(L.COLUMN_t)
	self.Columns.tag:SetText(L.COLUMN_tag)

	BINDING_HEADER_WOWQUOTE_HEADER = L.BINDING_HEADER
	BINDING_NAME_WOWQUOTE_TOGGLE = L.BINDING_TOGGLE

end

function SD_scrollBar() end


function WQUI:Initialize()
	UIPanelWindows[self:GetName()] = { area = "center", pushable = 5, whileDead = 1 };
	self:Localize()
	self.Items = {}



	-- create list items
	self.Items[1] = CreateFrame("Button", "SoundDeliveryItem1", self, "SoundDeliveryItemTemplate")
	self.Items[1]:SetPoint("TOPLEFT", self, "TOPLEFT", 20, -120) --letzer parameter -100



	for i=2,self.NUM_DISPLAYABLE do
		self.Items[i] = CreateFrame("Button", "SoundDeliveryItem"..i, self, "SoundDeliveryItemTemplate")
		self.Items[i]:SetPoint("TOPLEFT", self.Items[i-1], "BOTTOMLEFT", 0, 0)
	end

    self:UpdateCheckButtons()

end

function WQUI:UpdateItems()
  local numItems = # self.DisplayedItems;
	local scrollFrame = getglobal(self:GetName().."ScrollFrame")
	local offset = FauxScrollFrame_GetOffset(scrollFrame) or 0

	-- display quotes according to the scrollbar's offset
	for i=1,self.NUM_DISPLAYABLE do
		local button = self.Items[i]

		if (i <= numItems) then
			local media = self.DisplayedItems[i+offset]
			local buttonName = button:GetName()

			getglobal(buttonName.."LabelsText"):SetText(media.msg)
			getglobal(buttonName.."LabelsID"):SetText(media.id)
			if (media.len / 10 >= 1) then
				 if(media.len % 60 < 10) then
				     getglobal(buttonName.."LabelsDuration"):SetText(math.floor(media.len / 60)..":0"..media.len % 60)
				 else
			         getglobal(buttonName.."LabelsDuration"):SetText(math.floor(media.len / 60)..":"..media.len % 60)
				 end
			else
			     getglobal(buttonName.."LabelsDuration"):SetText("0:0"..media.len)
            end
			if (media.len == 0) then
			     getglobal(buttonName.."LabelsDuration"):SetText("??")
		    end
				--Check if the tag is a string
			if (not(type( media.tag ) == "string")) then
				getglobal(buttonName.."Labelstag"):SetText(" ")
			else
				getglobal(buttonName.."Labelstag"):SetText(media.tag)
			end

			button.id = media.id

			button:Show();
		else -- hide unused button if there are less quotes than buttons
			button:Hide();
		end
	end

	FauxScrollFrame_Update(scrollFrame, numItems, self.NUM_DISPLAYABLE, 16);
end

function WQUI:UpdateCheckButtons()
    self.CheckButtons.Guild:SetChecked(SD_SETTINGS.broadcast.GUILD);
    self.CheckButtons.Party:SetChecked(SD_SETTINGS.broadcast.PARTY);
    self.CheckButtons.Raid:SetChecked(SD_SETTINGS.broadcast.RAID);
end

function WQUI:SortItems(...)
	local arg = {...}
	self.sortNumber = self.sortNumber+1;
	if(not (self.Sorter == arg[1]) and not(self.Sorter == arg[2]))then
		self.sortNumber = 1;
	end
	if(self.sortNumber % 2 == 1) then
		if (arg[1]) then
			self.Sorter = arg[1]
		end
	else
		if (arg[2]) then
			self.Sorter = arg[2]
		end
	end
	sort(WQUI.DisplayedItems, self.Sorter)

end

function WQUI:OnSearch()

    --erst Tags filtern
    --evtl 2 methoden, sodass tags nur gefiltert werden, wenn sie sich ver�ndern

    if self.EditBox:GetText() ~= "" and self.EditBox:GetText() ~= SoundDeliveryUI_Localization.SEARCH  then
        --wenn Suchfester nicht leer und nicht default text: suchen
        local pattern = string.lower(self.EditBox:GetText());
        WQUI.DisplayedItems = {};

        for i,v in pairs(WQUI.FilteredItems) do
            if string.find(string.lower(v.msg), pattern) then
                table.insert(WQUI.DisplayedItems, v);
            end
        end
    else
        WQUI.DisplayedItems = WQUI.FilteredItems;
    end

    --SD_print("OnSearch: DisplayedItems length: "..#WQUI.DisplayedItems);

    self:SortItems();
    FauxScrollFrame_SetOffset(getglobal(self:GetName().."ScrollFrame"), 0);
    self:UpdateItems();


end

function WQUI.CategoryDropDown.OnClick(self)

    local tag = self.value;

    --SD_print("tag to filter: "..tostring(tag));


    WQUI.FilteredItems = SD_getFilteredMedia(WQUI.tagList[tag]);

    if not tag then
        tag = 0;
    end

    --SD_print("tag to show: "..tostring(tag));

    UIDropDownMenu_SetSelectedValue(SoundDeliveryDialogCategoryDropDown, tag);

	WQUI:OnSearch();
end


function WQUI.CategoryDropDown.Initialize()
	UIDropDownMenu_AddButton( {text=ALL, value=0, func=WQUI.CategoryDropDown.OnClick} );

    WQUI.tagList={};

    for i,v in pairs(SD_Tags) do
        table.insert(WQUI.tagList, {i,v})
    end
    table.sort(WQUI.tagList, function(a,b) return a[2]<b[2] end);

    for i,tag in ipairs(WQUI.tagList) do
		UIDropDownMenu_AddButton( {text=tag[2], value=i, func=WQUI.CategoryDropDown.OnClick, owner=SoundDeliveryDialog:GetParent()} );
	end

end

function WQUI.ChannelDropDown.OnClick(self)
	local channel = self:GetID()
	SD_SETTINGS.channel.CHANNEL = self:GetID()
	UIDropDownMenu_SetSelectedID(SoundDeliveryDialogChannelDropDown, channel);
	WQUI.Quote = WQUI.Channels[channel].func
end

function WQUI.ChannelDropDown.Initialize()
	for i=1, # WQUI.Channels do
        UIDropDownMenu_AddButton( {text=WQUI.Channels[i].name, func=WQUI.ChannelDropDown.OnClick, value=i} );
	end
end

--Used for the QuickButton

function WQUIB:Initialize()
	UIPanelWindows[self.getName()] = { area = "center", pushable = 5, whileDead = 1 };
end

--Used for the QuickButton to hide it, is called by SoundDelivery, via command

function WQUIB:Switch(boolean)

	if(boolean == true) then
		ShowUIPanel(WQUIB);
	else
		HideUIPanel(WQUIB);
	end
end

--Load function for the last loaded channel, called by SoundDelivery.lua

function WQUI.SetID(channel)

	UIDropDownMenu_SetSelectedID(SoundDeliveryDialogChannelDropDown, channel);
	UIDropDownMenu_SetText(SoundDeliveryDialogChannelDropDown,WQUI.Channels[channel].name)
	WQUI.Quote = WQUI.Channels[channel].func

end

--Checkbox Tooltip Function, called by UI.xml file

function WQUI_CheckBox_Tooltip_OnEnter(frame,message)
  GameTooltip_SetDefaultAnchor( GameTooltip, frame )
  GameTooltip:SetText( SoundDeliveryUI_Localization.TOOLTIPCHANNEL..SoundDeliveryUI_Localization[message]..SoundDeliveryUI_Localization.TOOLTIPCHANNEL_2,1,1,1)
	GameTooltip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 275, -50)
	GameTooltip:SetMinimumWidth(20, true);
  GameTooltip:Show()
end

--Universal Tooltip Function, called by UI.xml file

function WQUI_Universal_Tooltip_OnEnter(frame, message)
	GameTooltip_SetDefaultAnchor( GameTooltip, frame )
	GameTooltip:SetText( SoundDeliveryUI_Localization[message],1,1,1)
	GameTooltip:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 250, -50)
	GameTooltip:SetMinimumWidth(20, true);
  GameTooltip:Show()
end

--Universal Tooltip Function, called by UI.xml file

function WQUI_ToolTip_OnLeave()
	--GameTooltip:FadeOut()
  GameTooltip:Hide()
end

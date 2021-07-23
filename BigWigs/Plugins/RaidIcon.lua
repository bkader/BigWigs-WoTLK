-------------------------------------------------------------------------------
-- Module Declaration
--

local BigWigs = BigWigs
local plugin = BigWigs:NewPlugin("Raid Icons")
if not plugin then
	return
end

-------------------------------------------------------------------------------
-- Globals
--
local SetRaidTarget = SetRaidTarget
local GetRaidTargetIndex = GetRaidTargetIndex

-------------------------------------------------------------------------------
-- Locals
--

local lastplayer = {}

local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs")
local icons = {
	RAID_TARGET_1,
	RAID_TARGET_2,
	RAID_TARGET_3,
	RAID_TARGET_4,
	RAID_TARGET_5,
	RAID_TARGET_6,
	RAID_TARGET_7,
	RAID_TARGET_8,
	L["|cffff0000Disable|r"]
}

--------------------------------------------------------------------------------
-- Options
--

plugin.defaultDB = {
	disabled = false,
	icon = 8,
	secondIcon = 7
}

do
	local disabled = function()
		return plugin.db.profile.disabled
	end
	local function get(info)
		local key = info[#info]
		return plugin.db.profile[key]
	end
	local function set(info, index)
		plugin.db.profile[info[#info]] = index
	end

	plugin.pluginOptions = {
		type = "group",
		name = L["Icons"],
		get = get,
		set = set,
		args = {
			disabled = {
				type = "toggle",
				name = L["Disabled"],
				desc = L.raidIconsDesc,
				order = 1
			},
			description = {
				type = "description",
				name = L.raidIconDescription,
				order = 2,
				width = "full",
				fontSize = "medium",
				disabled = disabled
			},
			icon = {
				type = "select",
				name = L["Primary"],
				desc = L["The first raid target icon that a encounter script should use."],
				order = 3,
				values = icons,
				width = "full",
				disabled = disabled
			},
			secondIcon = {
				type = "select",
				name = L["Secondary"],
				desc = L["The second raid target icon that a encounter script should use."],
				order = 4,
				values = icons,
				width = "full",
				disabled = disabled
			}
		}
	}
end

-------------------------------------------------------------------------------
-- Initialization
--

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_SetRaidIcon")
	self:RegisterMessage("BigWigs_RemoveRaidIcon")
	self:RegisterMessage("BigWigs_OnBossDisable")
end

function plugin:BigWigs_OnBossDisable()
	if lastplayer[1] then
		SetRaidTarget(lastplayer[1], 0)
		lastplayer[1] = nil
	end
	if lastplayer[2] then
		SetRaidTarget(lastplayer[2], 0)
		lastplayer[2] = nil
	end
end

-------------------------------------------------------------------------------
-- Event Handlers
--

function plugin:BigWigs_SetRaidIcon(message, player, icon)
	if not BigWigs.db.profile.raidicon then
		return
	end
	if not player then
		return
	end
	if not GetRaidTargetIndex(player) then
		local index = (not icon or icon == 1) and self.db.profile.icon or self.db.profile.secondIcon
		if not index then
			return
		end
		SetRaidTarget(player, index)
		lastplayer[icon or 1] = player
	end
end

function plugin:BigWigs_RemoveRaidIcon(message, icon)
	if not BigWigs.db.profile.raidicon then
		return
	end
	if not lastplayer[icon or 1] then
		return
	end
	SetRaidTarget(lastplayer[icon or 1], 0)
	lastplayer[icon or 1] = nil
end
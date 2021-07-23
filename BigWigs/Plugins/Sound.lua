-------------------------------------------------------------------------------
-- Module Declaration
--

local plugin = BigWigs:NewPlugin("Sounds")
if not plugin then return end

-------------------------------------------------------------------------------
-- Locals
--

local media = LibStub("LibSharedMedia-3.0")
local mType = media.MediaType and media.MediaType.SOUND or "sound"
local soundList = nil

local sounds = {
	Long = "BigWigs: Long",
	Info = "BigWigs: Info",
	Alert = "BigWigs: Alert",
	Alarm = "BigWigs: Alarm",
	Victory = "BigWigs: Victory"
}
local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs")

local fmt = string.format
local setmetatable = setmetatable

local colorize = nil
do
	local r, g, b
	colorize = setmetatable({}, {__index = function(self, key)
		if not r then
			r, g, b = GameFontNormal:GetTextColor()
		end
		self[key] = "|cff" .. fmt("%02x%02x%02x", r * 255, g * 255, b * 255) .. key .. "|r"
		return self[key]
	end})
end

--------------------------------------------------------------------------------
-- Options
--

plugin.defaultDB = {
	defaultonly = false,
	media = {
		Long = "BigWigs: Long",
		Info = "BigWigs: Info",
		Alert = "BigWigs: Alert",
		Alarm = "BigWigs: Alarm",
		Victory = "BigWigs: Victory"
	}
}

plugin.pluginOptions = {
	type = "group",
	name = L["Sounds"],
	get = function(info)
		for i, v in next, soundList do
			if v == plugin.db.profile.media[info[#info]] then
				return i
			end
		end
	end,
	set = function(info, value)
		local sound = info[#info]
		PlaySoundFile(media:Fetch(mType, soundList[value]))
		plugin.db.profile.media[sound] = soundList[value]
	end,
	args = {
		default = {
			type = "toggle",
			name = colorize[L["Default only"]],
			desc = L.soundDefaultDescription,
			get = function(info)
				return plugin.db.profile.defaultonly
			end,
			set = function(info, v)
				plugin.db.profile.defaultonly = v
			end,
			order = 1,
			width = "full",
			descStyle = "inline"
		},
		resetAll = {
			type = "execute",
			name = L["Reset all"],
			desc = L["If you've customized colors for any boss encounter settings, this button will reset ALL of them so the colors defined here will be used instead."],
			func = function()
				plugin.db:ResetProfile()
			end,
			order = 3
		}
	}
}

-------------------------------------------------------------------------------
-- Initialization
--

local function shouldDisable()
	return plugin.db.profile.defaultonly
end
local function updateList(mediaType)
	if mediaType ~= mType then
		return
	end
	soundList = media:List(mType)
end

function plugin:OnRegister()
	media:Register(mType, "BigWigs: Long", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\Long.mp3")
	media:Register(mType, "BigWigs: Info", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\Info.mp3")
	media:Register(mType, "BigWigs: Alert", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\Alert.mp3")
	media:Register(mType, "BigWigs: Alarm", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\Alarm.mp3")
	media:Register(mType, "BigWigs: Victory", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\Victory.mp3")
	media:Register(mType, "BigWigs: Victory Long", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\VictoryLong.mp3")
	media:Register(mType, "BigWigs: Victory Classic", "Interface\\AddOns\\BigWigs\\Media\\Sounds\\VictoryClassic.mp3")

	media.RegisterCallback(self, "LibSharedMedia_Registered", updateList)
	soundList = media:List(mType)

	for k in pairs(sounds) do
		local n = L[k] or k
		self.pluginOptions.args[k] = {
			type = "select",
			name = n,
			order = 2,
			disabled = shouldDisable,
			values = soundList,
			width = "full"
		}
	end
end

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_Message")
	self:RegisterMessage("BigWigs_Sound")
end

local function play(sound)
	if type(sound) == "string" and not plugin.db.profile.defaultonly then
		local s =
			plugin.db.profile.media[sound] and media:Fetch(mType, plugin.db.profile.media[sound]) or
			media:Fetch(mType, sound)
		if type(s) == "string" then
			PlaySoundFile(s, "Master")
			return
		end
	end
	PlaySound("RaidWarning")
end

-------------------------------------------------------------------------------
-- Event Handlers
--

function plugin:BigWigs_Message(event, module, key, text, color, noraidsay, sound, broadcastonly)
	if not text or sound == false or broadcastonly or not BigWigs.db.profile.sound then return end
	play(sound)
end

function plugin:BigWigs_Sound(event, sound)
	if not BigWigs.db.profile.sound or sound == false then return end
	play(sound)
end
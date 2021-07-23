local plugin = BigWigs:NewPlugin("Voices")
if not plugin then
	return
end

local BigWigsLoader = BigWigsLoader
local L = LibStub("AceLocale-3.0"):GetLocale("Big Wigs")

local tostring, format = tostring, string.format
local PlaySoundFile = PlaySoundFile

plugin.defaultDB = {
	disabled = false
}

do
	local disabled = function()
		return BigWigs.db.profile.voice
	end
	plugin.pluginOptions = {
		type = "group",
		name = "Voices",
		get = disabled,
		set = function()
			BigWigs.db.profile.voice = not BigWigs.db.profile.voice
		end,
		args = {
			disabled = {
				type = "toggle",
				name = L["Disabled"],
				desc = "BigWigs has several boss abilities and mechanics ready as text-to-speech.\nIf you don't wish to play them, simply tick 'Disabled'.",
				order = 1,
				width = "full",
				descStyle = "inline"
			}
		}
	}
end

function plugin:OnPluginEnable()
	self:RegisterMessage("BigWigs_Voice")
end

function plugin:BigWigs_Voice(event, module, voicepath)
	if not BigWigs.db.profile.voice then
		local success = PlaySoundFile(voicepath, "Master")
		if not success then
			BigWigsLoader:SendMessage("BigWigs_Sound", module, voicepath)
		end
	end
end
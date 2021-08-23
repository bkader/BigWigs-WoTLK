-----------------------------------------------------------
-- Icecrown Gunship Battle
--

local mod = BigWigs:NewBoss("Icecrown Gunship Battle", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(37184) --Zafod Boombox
mod.toggleOptions = {"adds", "mage", "bosskill"}

local killed = nil

local adds_trigger_alliance = "Reavers, Sergeants, attack!"
local adds_trigger_horde = "Marines, Sergeants, attack!"
local warmup_trigger_alliance = "Fire up the engines"
local warmup_trigger_horde = "Rise up, sons and daughters"
local disable_trigger_alliance = "Onward, brothers and sisters"
local disable_trigger_horde = "Onward to the Lich King"

local L = mod:NewLocale("enUS", true)
if L then
	L.adds = "Portals"
	L.adds_desc = "Warn for Portals."
	L.adds_trigger_alliance = adds_trigger_alliance
	L.adds_trigger_horde = adds_trigger_horde
	L.adds_message = "Portals!"
	L.adds_bar = "Next Portals"

	L.mage = "Mage"
	L.mage_desc = "Warn when a mage spawns to freeze the gunship cannons."
	L.mage_message = "Mage Spawned!"
	L.mage_bar = "Next Mage"

	L.warmup_trigger_alliance = warmup_trigger_alliance
	L.warmup_trigger_horde = warmup_trigger_horde

	L.disable_trigger_alliance = disable_trigger_alliance
	L.disable_trigger_horde = disable_trigger_horde
end
L = mod:GetLocale()

function mod:OnBossEnable()
	self:Yell("Warmup", L["warmup_trigger_alliance"], L["warmup_trigger_horde"], warmup_trigger_alliance, warmup_trigger_horde)
	self:Yell("AddsPortal", L["adds_trigger_alliance"], L["adds_trigger_horde"], adds_trigger_alliance, adds_trigger_horde) --XXX unreliable, change to repeater
	self:Yell("Defeated", L["disable_trigger_alliance"], L["disable_trigger_horde"], disable_trigger_alliance, disable_trigger_horde)
	self:Log("SPELL_CAST_START", "Frozen", 69705)
	self:Log("SPELL_AURA_REMOVED", "FrozenCD", 69705)
	self:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
end

do
	local count = 0
	function mod:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
		count = count + 1
		if count == 2 then --2 bosses engaged
			count = 0
			local guid = UnitGUID("boss1")
			if guid then
				guid = tonumber(guid:sub(-12, -7), 16)
				if guid == 37540 or guid == 37215 then
					self:Engage()
				else
					self:Disable()
				end
			end
		end
	end
end

function mod:Warmup()
	self:Bar("adds", COMBAT, 45, "achievement_dungeon_hordeairship")
	self:Bar("adds", L["adds_bar"], 60, 53142)
	self:Voice(69705, -1, 72)
	self:Bar("mage", L["mage_bar"], 82, 69705)
end

function mod:VerifyEnable()
	if not killed then
		return true
	end
end

function mod:AddsPortal()
	self:Message("adds", L["adds_message"], "Attention", 53142)
	self:Voice("adds")
	self:Bar("adds", L["adds_bar"], 60, 53142) --Portal: Dalaran icon
end

function mod:Frozen(_, spellId)
	self:Voice(69705)
	self:Message("mage", L["mage_message"], "Positive", spellId, "Info")
end

function mod:FrozenCD(_, spellId)
	self:Voice(69705, -1, 25)
	self:Bar("mage", L["mage_bar"], 35, spellId)
end

function mod:Defeated()
	killed = true
	self:Win()
end
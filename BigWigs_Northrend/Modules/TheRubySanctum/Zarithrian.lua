--------------------------------------------------------------------------------
-- General Zarithrian
--

local mod = BigWigs:NewBoss("General Zarithrian", "The Ruby Sanctum")
if not mod then return end

mod.otherMenu = "Northrend"
mod:RegisterEnableMob(39746)
mod.toggleOptions = {74384, 74367, "bosskill"}

local L = mod:NewLocale("enUS", true)
if L then
	L.engage_trigger = "Alexstrasza has chosen capable allies.... A pity that I must END YOU!"
end
L = mod:GetLocale()

local sunder = GetSpellInfo(74367)
local fear = GetSpellInfo(74384)

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Fear", 74384)
	self:Log("SPELL_AURA_APPLIED", "Sunder", 74367)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Sunder", 74367)

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
	self:Yell("Engage", L.engage_trigger)
end

function mod:OnEngage()
	self:Bar(74367, sunder, 10, 74367)
	self:Bar(74384, fear, 15, 74384)
end

function mod:Fear(_, spellId)
	self:Bar(74384, fear, 33, spellId)
end

function mod:Sunder(_, spellId)
	self:Bar(74367, sunder, 15, spellId)
end
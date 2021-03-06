--------------------------------------------------------------------------------
-- Module declaration
--

local mod = BigWigs:NewBoss("Patchwerk", "Naxxramas")
if not mod then return end
mod:RegisterEnableMob(16028)
mod.toggleOptions = {28131, "berserk", "bosskill"}

--------------------------------------------------------------------------------
-- Localization
--
local starttrigger1 = "Patchwerk want to play!"
local starttrigger2 = "Kel'thuzad make Patchwerk his avatar of war!"

local L = mod:NewLocale("enUS", true)
if L then
	L.enragewarn = "5% - Frenzied!"
	L.starttrigger1 = starttrigger1
	L.starttrigger2 = starttrigger2
end
L = mod:GetLocale()

--------------------------------------------------------------------------------
-- Initialization
--

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Frenzy", 28131)
	self:Death("Win", 16028)

	self:Yell("Engage", L["starttrigger1"], L["starttrigger2"], starttrigger1, starttrigger2)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "CheckForWipe")
end

function mod:OnEngage()
	self:Berserk(360)
end

--------------------------------------------------------------------------------
-- Event Handlers
--

function mod:Frenzy(_, spellId)
	self:Message(28131, L["enragewarn"], "Attention", spellId, "Alarm")
end
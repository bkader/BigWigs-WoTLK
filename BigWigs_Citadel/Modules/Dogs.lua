-----------------------------------------------------------
-- Plaguework Dogs
--
local mod = BigWigs:NewBoss("Putricide Dogs", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(37217, 37025)
mod.toggleOptions = {71127, 71123}

local decimate

local L = mod:NewLocale("enUS", true)
if L then
	L.wound_message = "%2$dx Mortal Wound on %1$s"
end
L = mod:GetLocale()

function mod:OnBossEnable()
	decimate = GetSpellInfo(71123)
	self:Log("SPELL_CAST_START", "Decimate", 71123)
	self:Log("SPELL_AURA_APPLIED_DOSE", "Wound", 71127)
	self:Death("Disable", 37217, 37025)
end

function mod:Wound(player, spellId, _, _, _, stack)
	if stack > 5 then
		self:TargetMessage(71127, L["wound_message"], player, "Important", spellId, nil, stack)
	end
end

function mod:Decimate(_, spellId, _, _, spellName)
	self:Voice(71123, 0, 20)
	self:Message(71123, decimate, "Attention", spellId)
	self:Bar(71123, "~" .. decimate, 23, 71123)
end
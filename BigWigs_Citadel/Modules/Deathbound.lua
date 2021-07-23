-----------------------------------------------------------
-- Trash before Marrowgar
--

local mod = BigWigs:NewBoss("Deathbound Ward", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(37007)
mod.toggleOptions = {{71022, "FLASHSHAKE"}}

function mod:OnBossEnable()
	self:Log("SPELL_CAST_START", "Shout", 71022)
	self:Death("Deaths", 37007)
end

function mod:Shout(_, spellId, _, _, spellName)
	self:Message(71022, spellName, "Personal", spellId)
	self:Bar(71022, spellName, 3, spellId)
	self:Voice("stopcasting")
	self:FlashShake(71022)
end

function mod:Deaths()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "Disable")
end
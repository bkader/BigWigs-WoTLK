-----------------------------------------------------------
-- Trash before Lady Deathwhisper
--

local mod = BigWigs:NewBoss("Deathspeaker High Priest", "Icecrown Citadel")
if not mod then return end

mod:RegisterEnableMob(36805, 36807, 36808, 36811, 36829)
mod.toggleOptions = {{69483, "WHISPER", "ICON", "FLASHSHAKE"}, "proximity"}

function mod:OnBossEnable()
	self:Log("SPELL_AURA_APPLIED", "Reckoning", 69483)
	self:Log("SPELL_AURA_REMOVED", "SafeReckoning", 69483)
	self:Death("Deaths", 36829)
end

function mod:Reckoning(player, spellId, _, _, spellName)
	self:TargetMessage(69483, spellName, player, "Personal", spellId, "Alert")
	self:Bar(69483, spellName, 8, spellId)
	if UnitIsUnit(player, "player") then
		self:Voice(69483, true)
		self:FlashShake(69483)
		self:OpenProximity(15)
		self:ScheduleTimer(self.CloseProximity, 9, self)
	end
	self:Whisper(69483, player, spellName)
	self:PrimaryIcon(69483, player, "icon")
end

function mod:SafeReckoning()
	self:PrimaryIcon(69483)
end

do
	local deaths = 0
	function mod:Deaths()
		deaths = deaths + 1
		if deaths == 2 then
			self:Disable()
		end
	end
end